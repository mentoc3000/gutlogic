import {firestore} from "firebase-admin";
import {productDataMap} from "./products";
import {PurchaseHandler} from "./purchase-handler";
import {GooglePlayPurchaseHandler} from "./google-play.purchase-handler";
import {IapRepository, IAPSource} from "./iap.repository";
import {HttpsError} from "firebase-functions/lib/providers/https";

//
// Dependencies
//

const iapRepository = new IapRepository(firestore());
const purchaseHandlers: { [source in IAPSource]: PurchaseHandler } = {
  "google_play": new GooglePlayPurchaseHandler(iapRepository),
  // "app_store": new AppStorePurchaseHandler(iapRepository),
};

//
// Callables
//

// Verify Purchase Function
interface VerifyPurchaseParams {
  source: IAPSource;
  verificationData: string;
  productId: string;
}

// Handling of purchase verifications
export const verifyPurchase = async (
  data: VerifyPurchaseParams,
  context,
): Promise<boolean> => {
  // Check authentication
  if (!context.auth) {
    console.warn("verifyPurchase called when not authenticated");
    throw new HttpsError(
      "unauthenticated",
      "Request was not authenticated.",
    );
  }
  // Get the product data from the map
  const productData = productDataMap[data.productId];
  
  // If it was for an unknown product, do not process it.
  if (!productData) {
    console.warn(`verifyPurchase called for an unknown product ("${data.productId}")`);
    return false;
  }
  
  // If it was for an unknown source, do not process it.
  if (!purchaseHandlers[data.source]) {
    console.warn(`verifyPurchase called for an unknown source ("${data.source}")`);
    return false;
  }
  
  // Process the purchase for the product
  return purchaseHandlers[data.source].verifyPurchase(
    context.auth.uid,
    productData,
    data.verificationData,
  );
};

// Handling of PlayStore server-to-server events
export const handlePlayStoreServerEvent =
    (purchaseHandlers.google_play as GooglePlayPurchaseHandler)
      .handleServerEvent;