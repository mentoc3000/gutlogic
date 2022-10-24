import { Timestamp } from "firebase-admin/firestore";

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
  transactionDate: Timestamp;
}

export interface SubscriptionPurchase extends BasePurchase {
  type: "SUBSCRIPTION";
  expiryDate: Timestamp;
  status: SubscriptionStatus;
}

export interface PurchaseLog {
  premiumIapSource: string;
  premiumOrderId: string;
  premiumPurchaseDate: Timestamp;
  premiumExpirationDate: Timestamp;
  premiumStatus: string;
}

export class IapRepository {
  constructor(private firestore: FirebaseFirestore.Firestore) {
  }

  async getUserIdFrom(source: string, originalTransactionId: string): Promise<string> {
    const snapshot = await this.firestore
      .collection("users")
      .where("premiumOrderId", "==", originalTransactionId)
      .where("premiumIapSource", "==", source)
      .where("premiumStatus", "!=", "TRANSFERRED")
      .get();

    if (snapshot.empty) {
      return null;
    }

    if (snapshot.size > 1) {
      throw Error("Multiple users found");
    }

    const doc = snapshot.docs.pop();
    return doc.id;
  }

  async isActive(source: string, originalTransactionId: string): Promise<boolean> {
    const snapshot = await this.firestore
      .collection("users")
      .where("premiumOrderId", "==", originalTransactionId)
      .where("premiumIapSource", "==", source)
      .where("premiumStatus", "==", "ACTIVE")
      .get();

    if (snapshot.empty) {
      return false;
    }

    if (snapshot.size > 1) {
      throw Error("Multiple users found");
    }

    return true;
  }

  async updatePurchase({ userId, purchaseData }:
    { userId: string; purchaseData: Partial<PurchaseLog>; }
  ): Promise<void> {
    await this.firestore
      .collection("users")
      .doc(userId)
      .set(purchaseData, { merge: true });
  }

  async expireSubscriptions(): Promise<void> {
    const snapshot = await this.firestore.collection("users")
      .where("premiumStatus", "==", "ACTIVE")
      .where("premiumExpirationDate", "<", Timestamp.now())
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
