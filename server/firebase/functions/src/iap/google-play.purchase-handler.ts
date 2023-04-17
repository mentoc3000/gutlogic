import { PurchaseHandler } from "./purchase-handler";
import { ProductData, productDataMap } from "./products";
import { packageName } from "../config.json";
import { GoogleAuth } from "google-auth-library";
import { androidpublisher_v3 as AndroidPublisherApi } from "googleapis";
import credentials from "./google_play_console_cloud_functions_key.json";
import {
  IapRepository, PurchaseLog, SubscriptionStatus,
} from "./iap.repository";
import { Timestamp } from "firebase-admin/firestore";


export class GooglePlayPurchaseHandler extends PurchaseHandler {
  private androidPublisher: AndroidPublisherApi.Androidpublisher;

  constructor(private iapRepository: IapRepository) {
    super();
    this.androidPublisher = new AndroidPublisherApi.Androidpublisher({
      auth: new GoogleAuth(
        {
          credentials,
          scopes: ["https://www.googleapis.com/auth/androidpublisher"],
        }),
    });
  }

  async handleSubscription(
    userId: string | null,
    productData: ProductData,
    token: string,
  ): Promise<boolean> {
    try {
      // Verify the purchase with Google
      let response = await this.androidPublisher.purchases.subscriptions.get(
        {
          packageName: packageName,
          subscriptionId: productData.productId,
          token,
        },
      );

      if (!response.data.orderId) {
        console.error("Could not handle purchase without order id");
        return false;
      }

      // If a subscription suffix is present (..#) extract the orderId.
      let orderId = response.data.orderId;
      const orderIdMatch = /^(.+)?[.]{2}[0-9]+$/g.exec(orderId);
      if (orderIdMatch) {
        orderId = orderIdMatch[1];
      }
      console.log({
        rawOrderId: response.data.orderId,
        newOrderId: orderId,
      });

      // Construct purchase data for db updates
      const purchaseLog: PurchaseLog = {
        premiumIapSource: "google_play",
        premiumOrderId: orderId,
        premiumPurchaseDate: Timestamp.fromMillis(parseInt(response.data.startTimeMillis ?? "0", 10)),
        premiumExpirationDate: Timestamp.fromMillis(parseInt(response.data.expiryTimeMillis ?? "0", 10)),
        premiumStatus: [
          "PENDING", // Payment pending
          "ACTIVE", // Payment received
          "ACTIVE", // Free trial
          "PENDING", // Pending deferred upgrade/downgrade
          "EXPIRED", // Expired or cancelled
        ][response.data.paymentState ?? 4] as SubscriptionStatus,
      };

      try {
        await this.iapRepository.updatePurchase({ userId, purchaseLog });

      } catch (e) {
        console.log("Could not create or update purchase", { orderId, productId: productData.productId });
      }

      return true;

    } catch (e) {
      console.error(e);
      return false;
    }
  }

  handleServerEvent = async (message: { data: string; }) => {
      // Define the event
      // https://developer.android.com/google/play/billing/rtdn-reference
      type GooglePlayOneTimeProductNotification = {
        "version": string;
        "notificationType": number;
        "purchaseToken": string;
        "sku": string;
      };
      type GooglePlaySubscriptionNotification = {
        "version": string;
        "notificationType": number;
        "purchaseToken": string;
        "subscriptionId": string;
      };
      type GooglePlayTestNotification = {
        "version": string;
      };
      type GooglePlayBillingEvent = {
        "version": string;
        "packageName": string;
        "eventTimeMillis": number;
        "oneTimeProductNotification": GooglePlayOneTimeProductNotification;
        "subscriptionNotification": GooglePlaySubscriptionNotification;
        "testNotification": GooglePlayTestNotification;
      };

      let event: GooglePlayBillingEvent;
      // Parse the event data
      try {
        event = JSON.parse(new Buffer(message.data, "base64").toString("ascii"));
      } catch (e) {
        console.error("Could not parse Google Play billing event", e);
        return;
      }

      // Skip test events
      if (event.testNotification) return;

      // Extract event data
      const { purchaseToken, subscriptionId, sku } = {
        ...event.subscriptionNotification,
        ...event.oneTimeProductNotification,
      };

      // Get the product for this event
      const productData = productDataMap[subscriptionId ?? sku];

      // Skip products that are unknown
      if (!productData) return;

      // Skip products that do not match the notification type
      const notificationType = subscriptionId ? "SUBSCRIPTION" : null;
      if (productData.type !== notificationType) return;

      // Handle notifications
      switch (notificationType) {
      case "SUBSCRIPTION":
        await this.handleSubscription(null, productData, purchaseToken);
        break;
      }
  };
}
