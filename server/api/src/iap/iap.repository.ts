import * as firestore from "firebase-admin/firestore";

export type NonSubscriptionStatus = "PENDING" | "COMPLETED" | "CANCELLED";
export type SubscriptionStatus = "PENDING" | "ACTIVE" | "EXPIRED";

// export type IAPSource = "google_play" | "app_store";
export type IAPSource = "app_store";
// export type Purchase = NonSubscriptionPurchase | SubscriptionPurchase;
export type Purchase = SubscriptionPurchase;

export interface BasePurchase {
  iapSource: IAPSource;
  orderId: string;
  productId: string;
  userId: string;
  transactionDate: firestore.Timestamp;
}

export interface SubscriptionPurchase extends BasePurchase {
  type: "SUBSCRIPTION";
  expiryDate: firestore.Timestamp;
  status: SubscriptionStatus;
}

export interface PurchaseLog {
  premiumIapSource: string;
  premiumOrderId: string;
  premiumPurchaseDate: firestore.Timestamp;
  premiumExpirationDate: firestore.Timestamp;
  premiumStatus: string;
}

export class IapRepository {
  constructor(private firestore: FirebaseFirestore.Firestore) {
  }

  async getUserIdFrom(originalTransactionId: string): Promise<string> {
    const snapshot = await this.firestore
      .collection("users")
      .where("premiumOrderId", "==", originalTransactionId)
      .get();

    if (snapshot.empty) {
      throw Error("User not found");
    }

    if (snapshot.size > 1) {
      throw Error("Multiple users found");
    }

    const doc = snapshot.docs.pop();
    return doc.id;
  }

  async updatePurchase({ userId, purchaseData }:
    { userId: string; purchaseData: { premiumIapSource: IAPSource; premiumOrderId: string; } & Partial<PurchaseLog>; }
  ): Promise<void> {
    await this.firestore
      .collection("users")
      .doc(userId)
      .set(purchaseData, { merge: true });
  }

  async expireSubscriptions(): Promise<void> {
    const snapshot = await this.firestore.collection("users")
      .where("premiumExpirationDate", "<", firestore.Timestamp.now())
      .where("premiumStatus", "==", "ACTIVE")
      .get();
    if (!snapshot.size) return;
    const writeBatch = this.firestore.batch();
    snapshot.docs.forEach((doc) =>
      writeBatch.update(doc.ref, { premiumStatus: 'EXPIRED' })
    );
    await writeBatch.commit();
    console.log(`Expired ${snapshot.size} subscriptions`);
  }
}
