export interface ProductData {
  productId: string;
  type: "SUBSCRIPTION" | "NON_SUBSCRIPTION";
}

export const productDataMap: { [productId: string]: ProductData; } = {
  "premium_subscription": {
    productId: "premium_subscription",
    type: "SUBSCRIPTION",
  },
  "premium_subscription_dev": {
    productId: "premium_subscription_dev",
    type: "SUBSCRIPTION",
  },
};
