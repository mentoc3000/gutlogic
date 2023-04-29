import { DocumentReference, Timestamp } from "firebase-admin/firestore";

export type NonSubscriptionStatus = "PENDING" | "COMPLETED" | "CANCELLED";
export type SubscriptionStatus = "PENDING" | "ACTIVE" | "EXPIRED";

// export type IAPSource = "google_play" | "app_store";
export type IAPSource = "google_play";
export type Purchase = SubscriptionPurchase;

export interface BasePurchase {
  iapSource: IAPSource;
  orderId: string;
  productId: string;
  userId: string;
  purchaseDate: Timestamp;
}

export interface PurchaseLog {
  premiumIapSource: string;
  premiumOrderId: string;
  premiumPurchaseDate: Timestamp;
  premiumExpirationDate: Timestamp;
  premiumStatus: string;
}

export interface SubscriptionPurchase extends BasePurchase {
  type: "SUBSCRIPTION";
  expiryDate: Timestamp;
  status: SubscriptionStatus;
}

export class IapRepository {
  constructor(private firestore: FirebaseFirestore.Firestore) {
  }

  async createOrUpdatePurchase({ userId, purchaseLog }:
    { userId: string; purchaseLog: Partial<PurchaseLog>; }
  ): Promise<void> {
    await this.firestore
      .collection("users")
      .doc(userId)
      .set(purchaseLog, { merge: true });
  }

  async updatePurchase({  purchaseLog }:
    { purchaseLog: Partial<PurchaseLog>; }
  ): Promise<void> {
    const querySnapshot= await this.firestore
      .collection("users")
      .where("premiumOrderId", "==", purchaseLog.premiumOrderId)
      .get();

    if (querySnapshot.size === 0) {
      console.warn(`No matching documents for order id ${purchaseLog.premiumOrderId}.`);
      return;
    }

    if (querySnapshot.size > 1) {
      console.warn(`More than one matching documents for order id ${purchaseLog.premiumOrderId}.`);
      console.log("Updating purchase for all matches.")
    }

    await Promise.all(querySnapshot.docs.map(async (doc) => {
      await doc.ref.set(purchaseLog, { merge: true });
    }));
  }
   
}
