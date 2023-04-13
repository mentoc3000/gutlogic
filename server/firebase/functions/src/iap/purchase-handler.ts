import {ProductData} from "./products";

export abstract class PurchaseHandler {
  async verifyPurchase(
    userId: string,
    productData: ProductData,
    token: string,
  ): Promise<boolean> {
    switch (productData.type) {
    case "SUBSCRIPTION":
      return this.handleSubscription(userId, productData, token);
    default:
      return false;
    }
  }

  abstract handleSubscription(
      userId: string,
      productData: ProductData,
      token: string,
  ): Promise<boolean>;
}
