// Derived from https://github.com/flutter/codelabs/tree/master/in_app_purchases/complete/firebase-backend/functions/src

import * as admin from "firebase-admin";
import { PurchaseHandler } from "./purchase-handler";
import { AppStorePurchaseHandler } from "./app-store.purchase-handler";
import { IapRepository, IAPSource } from "./iap.repository";
import express from "express";
import log from '../resources/logger';

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

// Handling of AppStore server-to-server events
const handleAppStoreServerEvent = (purchaseHandlers.app_store as AppStorePurchaseHandler)
  .handleServerEvent;

// Handling of PlayStore server-to-server events
// export const handlePlayStoreServerEvent =
//     (purchaseHandlers.google_play as GooglePlayPurchaseHandler)
//         .handleServerEvent;

const router = express.Router();

router.post("/app_store", handleAppStoreServerEvent);

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
