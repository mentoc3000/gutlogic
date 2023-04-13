import { Timestamp } from "firebase-admin/firestore";

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

  async updatePurchase({ userId, purchaseLog }:
    { userId: string; purchaseLog: Partial<PurchaseLog>; }
  ): Promise<void> {
    await this.firestore
      .collection("users")
      .doc(userId)
      .set(purchaseLog, { merge: true });
  }
}
