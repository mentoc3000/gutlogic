export interface ProductData {
  productId: string;
  type: "SUBSCRIPTION";
}

export const productDataMap: { [productId: string]: ProductData } = {
  "premium_subscription_monthly": {
    productId: "premium_subscription_monthly",
    type: "SUBSCRIPTION",
  },
};
