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

type UserSubscription = {
  hasActivePremiumSubscription: boolean;
  premiumSubscriptionExpirationDate: firestore.Timestamp;
};

export class IapRepository {
  constructor(private firestore: FirebaseFirestore.Firestore) {
  }

  async purchasePremium({ userId, expirationDateMs }: { userId: string; expirationDateMs: number; }): Promise<void> {
    const premiumSubscriptionExpirationDate = firestore.Timestamp.fromMillis(expirationDateMs);
    const data: UserSubscription = {
      hasActivePremiumSubscription: true,
      premiumSubscriptionExpirationDate,
    };
    await this.firestore
      .collection("users")
      .doc(userId)
      .update(data);
  }

  async logTransaction({ userId, transaction }: { userId: string; transaction: any; }): Promise<void> {
    await this.firestore
      .collection("users")
      .doc(userId)
      .collection("iap_transactions")
      .add(transaction);
  }

  async expireSubscriptions(): Promise<void> {
    const snapshot = await this.firestore.collection("users")
      .where("premiumSubscriptionExpirationDate", "<", firestore.Timestamp.now())
      .get();
    if (!snapshot.size) return;
    const writeBatch = this.firestore.batch();
    snapshot.docs.forEach((doc) =>
      writeBatch.update(doc.ref,
        {
          hasActivePremiumSubscription: false,
          premiumSubscriptionExpirationDate: null,
        },
      )
    );
    await writeBatch.commit();
    console.log(`Expired ${snapshot.size} subscriptions`);
  }
}
