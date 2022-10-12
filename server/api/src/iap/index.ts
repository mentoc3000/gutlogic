// Derived from https://github.com/flutter/codelabs/tree/master/in_app_purchases/complete/firebase-backend/functions/src

import * as admin from "firebase-admin";
import { PurchaseHandler } from "./purchase-handler";
import { AppStorePurchaseHandler } from "./app-store.purchase-handler";
import { IapRepository, IAPSource } from "./iap.repository";
import express, { Request, Response } from "express";
import log from '../resources/logger';
import { isRegularExpressionLiteral } from 'typescript';
import authMiddleware from '../resources/auth';
import { productDataMap } from './products';
import { equal } from 'assert';

//
// Dependencies
//

const iapRepository = new IapRepository(admin.firestore());
const purchaseHandlers: { [source in IAPSource]: PurchaseHandler } = {
  // "google_play": new GooglePlayPurchaseHandler(iapRepository),
  "app_store": new AppStorePurchaseHandler(iapRepository),
};

//
// Callables
//

// Verify Purchase Function
interface VerifyPurchaseParams {
  userId: string;
  source: IAPSource;
  verificationData: string;
  productId: string;
}

// Handling of purchase verifications
const verifyPurchase = async function verifyPurchase(
  req: Request<unknown, unknown, VerifyPurchaseParams>, res: Response): Promise<void> {
  log.d(`Received verification message ${JSON.stringify(req.body)}`);

  // Get the product data from the map
  const productData = productDataMap[req.body.productId];

  // If it was for an unknown product, do not process it.
  if (!productData) {
    console.warn(`verifyPurchase called for an unknown product ("${req.body.productId}")`);
    res.status(400).end();
    return;
  }

  // If it was for an unknown source, do not process it.
  if (!purchaseHandlers[req.body.source]) {
    console.warn(`verifyPurchase called for an unknown source ("${req.body.source}")`);
    res.status(400).end();
    return;
  }

  log.d(`Verifying transaction ${JSON.stringify(productData)}`);

  // Process the purchase for the product
  const verified = await purchaseHandlers[req.body.source].verifyPurchase(
    req.body.userId,
    productData,
    req.body.verificationData,
  );

  if (verified) {
    res.status(200).end();
  } else {
    res.status(400).end();
  }
};

// Handling of AppStore server-to-server events
const handleAppStoreServerEvent = (purchaseHandlers.app_store as AppStorePurchaseHandler)
  .handleServerEvent;

// Handling of PlayStore server-to-server events
// export const handlePlayStoreServerEvent =
//     (purchaseHandlers.google_play as GooglePlayPurchaseHandler)
//         .handleServerEvent;

const router = express.Router();

router.post("/app_store", handleAppStoreServerEvent);
router.post("/verify", authMiddleware, verifyPurchase);

export default router;

// Scheduled job for expiring subscriptions in the case of missing store events
export function startSubscriptionRevocationCheck() {
  const revocationInterval = 60 * 60 * 1000; // 1 hour, to reduce cost
  setInterval(() => {
    try {
      iapRepository.expireSubscriptions();
    } catch (e) {
      log.e(JSON.stringify(e));
    }
  }, revocationInterval);
}
