/* eslint-disable no-fallthrough */
import { PurchaseHandler } from "./purchase-handler";
import { productDataMap } from "./products";
import { IapRepository } from "./iap.repository";
import { Request, Response } from "express";
import { decodeNotificationPayload, decodeRenewalInfo, decodeTransaction } from "../app-store-server-api/Decoding";
import {
  Environment,
  JWSRenewalInfoDecodedPayload,
  JWSTransactionDecodedPayload,
  NotificationSubtype,
  NotificationType,
  ResponseBodyV2,
  Timestamp,
} from "../app-store-server-api/Models";
import log from "../resources/logger";

export type DecodedNotificationData = {
  appAppleId?: string;
  bundleId: string;
  bundleVersion?: number;
  environment: Environment;
  renewalInfo?: JWSRenewalInfoDecodedPayload;
  transactionInfo?: JWSTransactionDecodedPayload;
};

export type DecodedNotification = {
  notificationType: NotificationType;
  subtype?: NotificationSubtype;
  notificationUUID: string;
  version: string;
  signedDate: Timestamp;
  data: DecodedNotificationData;
};

async function decodeNotification(body: ResponseBodyV2): Promise<DecodedNotification> {
  const event = await decodeNotificationPayload(body.signedPayload);
  const eventData = event.data;
  const renewalInfo = eventData.signedRenewalInfo ? await decodeRenewalInfo(eventData.signedRenewalInfo) : undefined;
  const transactionInfo = eventData.signedTransactionInfo ? await decodeTransaction(eventData.signedTransactionInfo) : undefined;
  return {
    notificationType: event.notificationType,
    subtype: event.subtype,
    notificationUUID: event.notificationUUID,
    version: event.version,
    signedDate: event.signedDate,
    data: {
      appAppleId: eventData.appAppleId,
      bundleId: eventData.bundleId,
      bundleVersion: eventData.bundleVersion,
      environment: eventData.environment,
      renewalInfo: renewalInfo,
      transactionInfo: transactionInfo,
    },
  };
}

export class AppStorePurchaseHandler extends PurchaseHandler {
  constructor(private iapRepository: IapRepository) {
    super();

    this.handleServerEvent = this.handleServerEvent.bind(this);
    this.handleEvent = this.handleEvent.bind(this);
    this.purchase = this.purchase.bind(this);
    this.undoPurchase = this.undoPurchase.bind(this);
    this.unsubscribe = this.unsubscribe.bind(this);
  }

  async handleServerEvent(req: Request<unknown, unknown, ResponseBodyV2>, res: Response): Promise<void> {

    var event: DecodedNotification;
    try {
      event = await decodeNotification(req.body);
      log.d(`App Store notification received: ${event.notificationType}`);
    } catch (e) {
      const err = JSON.stringify(e, Object.getOwnPropertyNames(e));
      log.e(`Failed with error ${err} to decode notification ${JSON.stringify(req.body)}`);
      res.status(403).end();
      return;
    }

    try {
      if (event.data?.transactionInfo?.appAccountToken) {
        await this.iapRepository.logTransaction({
          userId: event.data.transactionInfo.appAccountToken,
          transaction: event,
        });
      }
    } catch (e) {
      log.e(`Failed to log notification ${event.notificationUUID}`);
      res.status(400).end();
      return;
    }

    await this.handleEvent(event, res);
  }

  async handleEvent(event: DecodedNotification, res: Response): Promise<void> {

    switch (event.notificationType) {
      case NotificationType.ConsumptionRequest:
        // Notification not expected from App Store API
        log.w(`Unexpected notification type: ${event.notificationType}`);
        res.status(200).end();
        return;

      case NotificationType.DidChangeRenewalPref:
        // User made change to subscription plan
        switch (event.subtype) {
          case NotificationSubtype.Upgrade:
          // Plan changes apply immediately
          case NotificationSubtype.Downgrade:
          // Plan changes apply at next renewal
          case undefined:
          case null:
            // Subscription level unchanged
            res.status(200).end();
            return;

          default:
            // Unexpected subtype
            log.w(`Unexpected notification subtype: ${event.subtype}`);
            res.status(200).end();
            return;
        }

      case NotificationType.DidChangeRenewalStatus:
        // Auto renew enabled or disabled
        // Accept without action
        res.status(200).end();
        return;

      case NotificationType.DidFailToRenew:
        // Billing issue occured
        switch (event.subtype) {
          case NotificationSubtype.GracePeriod:
            // Continue to provide service through grace period
            res.status(200).end();
            return;

          case undefined:
          case null: {
            // Grace period has ended. Cancel subscription
            const status = await this.unsubscribe(event.data);
            res.status(status).end();
            return;
          }

          default:
            // Unexpected subtype
            log.w(`Unexpected notification subtype: ${event.subtype}`);
            res.status(200).end();
            return;
        }

      case NotificationType.DidRenew:
        // Subscription renewal success
        switch (event.subtype) {
          case NotificationSubtype.BillingRecovery:
          // Expired subscription that previously failed to renew now successfully renewed
          case undefined:
          case null: {
            // Active subscription has successfully auto renewed
            const status = await this.purchase(event.data);
            res.status(status).end();
            return;
          }

          default:
            // Unexpected subtype
            log.w(`Unexpected notification subtype: ${event.subtype}`);
            res.status(200).end();
            return;
        }

      case NotificationType.Expired:
        // Subscription expired
        switch (event.subtype) {
          case NotificationSubtype.Voluntary:
          // User disabled subscription renewal
          case NotificationSubtype.BillingRetry:
          // Billin gretry period ended without a successful transaction
          case NotificationSubtype.PriceIncrease: {
            // User did not consent to price increase
            const status = await this.unsubscribe(event.data);
            res.status(status).end();
            return;
          }

          default:
            // Unexpected subtype
            log.w(`Unexpected notification subtype: ${event.subtype}`);
            res.status(200).end();
            return;
        }

      case NotificationType.GracePeriodExpired: {
        // Billing grace period has ended without renewal
        const status = await this.unsubscribe(event.data);
        res.status(status).end();
        return;
      }

      case NotificationType.OfferRedeemed:
        // user redeemed a promotional offer or offer code
        switch (event.subtype) {
          case NotificationSubtype.InitialBuy:
          // User redeemed an offer for a first-time purchase
          case NotificationSubtype.Resubscribe: {
            // User redeemed an offer for a renewal
            const status = await this.purchase(event.data);
            res.status(status).end();
            return;
          }

          case undefined:
          case null:
            // User redeemed an offer for their active subscription
            res.status(200).end();
            return;

          case NotificationSubtype.Upgrade:
          case NotificationSubtype.Downgrade:
          default:
            // Unexpected subtype
            log.w(`Unexpected notification subtype: ${event.subtype}`);
            res.status(200).end();
            return;
        }

      case NotificationType.PriceIncrease:
        // System has informed user of an auto-renewable subscription price increase
        switch (event.subtype) {
          case NotificationSubtype.Pending:
          // User has not yet responsed to price increase
          case NotificationSubtype.Accepted:
            // User has consented to the price increase
            res.status(200).end();
            return;

          default:
            // Unexpcted subtype
            log.w(`Unexpected notification subtype: ${event.subtype}`);
            res.status(200).end();
            return;
        }

      case NotificationType.Refund: {
        // App Store successfully refunded a transaction
        const status = await this.undoPurchase(event.data);
        res.status(status).end();
        return;
      }

      case NotificationType.RefundDeclined:
        // App Store declined a refund req initiated by the app developer
        log.i(`Refund declined for user ${event.data?.transactionInfo?.appAccountToken}`);
        res.status(200).end();
        return;

      case NotificationType.RenewalExtended: {
        // App Store extended the subscription renewal date requested by the developer
        const status = await this.purchase(event.data);
        res.status(status).end();
        return;
      }

      case NotificationType.Revoke: {
        // In-app purchase through family sharing is no longer available
        const status = await this.undoPurchase(event.data);
        res.status(status).end();
        return;
      }

      case NotificationType.Subscribed:
        switch (event.subtype) {
          case NotificationSubtype.InitialBuy:
          // User subscribed for the first time
          case NotificationSubtype.Resubscribe: {
            // User resubscribed
            // BUG: this is undefined; add tests
            const status = await this.purchase(event.data);
            res.status(status).end();
            return;
          }

          default:
            // Unexpected subtype
            log.w(`Unexpected notification subtype: ${event.subtype}`);
            res.status(200).end();
            return;
        }

      case NotificationType.Test:
        // Accept without action
        log.i("Test notification received");
        res.status(200).end();
        return;

      default:
        // Unrecognized notification type
        log.w(`Unexpected notification type: ${event.notificationType}`);
        res.status(200).end();
        return;
    }
  }

  async purchase(data: DecodedNotificationData): Promise<number> {
    const userId = data.transactionInfo?.appAccountToken;
    const expirationDate = data.transactionInfo?.expiresDate;

    if (!(expirationDate)) {
      log.w(`Transaction for user ${userId} missing expiration date`);
      return 400;
    }

    const productId = data.transactionInfo?.productId;
    if (productId !== productDataMap.premium_subscription_monthly.productId) {
      log.e(`Unknown productId ${productId} in transaction ${data.transactionInfo?.transactionId}`);
      return 200;
    }

    try {
      await this.iapRepository.purchasePremium({ userId: userId!, expirationDateMs: expirationDate! });
    } catch (e) {
      const err = JSON.stringify(e, Object.getOwnPropertyNames(e));
      log.w(`Failed to execute purchase for transaction ${data.transactionInfo?.transactionId} with error ${err}`);
      return 400;
    }
    return 200;
  }

  async undoPurchase(data: DecodedNotificationData): Promise<number> {
    const productId = data.transactionInfo?.productId;
    if (productId !== productDataMap.premium_subscription_monthly.productId) {
      log.e(`Unknown productId ${productId} in transaction ${data.transactionInfo?.transactionId}`);
      return 200;
    }

    // TODO: Reset expiration date to prior value
    log.e(
      `Undo purchase requested by user ${data.transactionInfo?.appAccountToken} but server functionality is not implemented`,
    );

    return 200;
  }

  async unsubscribe(data: DecodedNotificationData): Promise<number> {
    const productId = data.transactionInfo?.productId;
    if (productId !== productDataMap.premium_subscription_monthly.productId) {
      log.e(`Unknown productId ${productId} in transaction ${data.transactionInfo?.transactionId}`);
      return 200;
    }

    return 200;
  }
}
