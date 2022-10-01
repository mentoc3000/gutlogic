export enum Environment {
  Production = "Production",
  Sandbox = "Sandbox",
}

/**
 * UNIX timestamp in milliseconds
 */
export type Timestamp = number;

export enum SortParameter {
  Ascending = "ASCENDING",
  Descending = "DESCENDING",
}

export enum ProductTypeParameter {
  AutoRenewable = "AUTO_RENEWABLE",
  NonRenewable = "NON_RENEWABLE",
  Consumable = "CONSUMABLE",
  NonConsumable = "NON_CONSUMABLE",
}

/**
 * The query parameters that can be passed to the history endpoint
 * to filter results and change sort order.
 */
export interface TransactionHistoryQuery {
  revision?: string;
  sort?: SortParameter;
  startDate?: Timestamp;
  endDate?: Timestamp;
  productType?: ProductTypeParameter;
  productId?: string;
  subscriptionGroupIdentifier?: string;
  inAppOwnershipType?: OwnershipType;
  excludeRevoked?: boolean;
}

// https://developer.apple.com/documentation/appstoreserverapi/historyresponse
export interface HistoryResponse {
  appAppleId: string;
  bundleId: string;
  environment: Environment;
  hasMore: boolean;
  revision: string;
  signedTransactions: JWSTransaction[];
}

// https://developer.apple.com/documentation/appstoreserverapi/jwstransaction
export type JWSTransaction = string;

// https://developer.apple.com/documentation/appstoreserverapi/jwsdecodedheader
export interface JWSDecodedHeader {
  alg: string;
  x5c: string[];
}

// https://developer.apple.com/documentation/appstoreserverapi/jwstransactiondecodedpayload
export interface JWSTransactionDecodedPayload {
  appAccountToken?: string;
  bundleId: string;
  environment: Environment;
  expiresDate?: Timestamp;
  inAppOwnershipType: OwnershipType;
  isUpgraded?: boolean;
  offerIdentifier?: string;
  offerType?: OfferType;
  originalPurchaseDate: Timestamp;
  originalTransactionId: string;
  productId: string;
  purchaseDate: Timestamp;
  quantity: number;
  revocationDate?: Timestamp;
  revocationReason?: RevocationReason;
  signedDate: Timestamp;
  subscriptionGroupIdentifier?: string;
  transactionId: string;
  type: TransactionType;
  webOrderLineItemId: string;
}

export enum RevocationReason {
  Issue = 1,
  Accident = 0,
}

// https://developer.apple.com/documentation/appstoreserverapi/inappownershiptype
export enum OwnershipType {
  Purchased = "PURCHASED",
  FamilyShared = "FAMILY_SHARED",
}

// https://developer.apple.com/documentation/appstoreserverapi/type
export enum TransactionType {
  AutoRenewableSubscription = "Auto-Renewable Subscription",
  NonConsumable = "Non-Consumable",
  Consumable = "Consumable",
  NonRenewingSubscription = "Non-Renewing Subscription",
}

// https://developer.apple.com/documentation/appstoreserverapi/statusresponse
export interface StatusResponse {
  data: SubscriptionGroupIdentifierItem[];
  environment: Environment;
  appAppleId: string;
  bundleId: string;
}

// https://developer.apple.com/documentation/appstoreserverapi/subscriptiongroupidentifieritem
export interface SubscriptionGroupIdentifierItem {
  subscriptionGroupIdentifier: string;
  lastTransactions: LastTransactionsItem[];
}

// https://developer.apple.com/documentation/appstoreserverapi/lasttransactionsitem
export interface LastTransactionsItem {
  originalTransactionId: string;
  status: SubscriptionStatus;
  signedRenewalInfo: JWSRenewalInfo;
  signedTransactionInfo: JWSTransaction;
}

// https://developer.apple.com/documentation/appstoreserverapi/jwsrenewalinfo
export type JWSRenewalInfo = string;

// https://developer.apple.com/documentation/appstoreserverapi/status
export enum SubscriptionStatus {
  Active = 1,
  Expired = 2,
  InBillingRetry = 3,
  InBillingGracePeriod = 4,
  Revoked = 5,
}

// https://developer.apple.com/documentation/appstoreserverapi/jwsrenewalinfodecodedpayload
export interface JWSRenewalInfoDecodedPayload {
  autoRenewProductId: string;
  autoRenewStatus: AutoRenewStatus;
  environment: Environment;
  expirationIntent?: ExpirationIntent;
  gracePeriodExpiresDate?: Timestamp;
  isInBillingRetryPeriod?: boolean;
  offerIdentifier?: string;
  offerType?: OfferType;
  originalTransactionId: string;
  priceIncreaseStatus?: PriceIncreaseStatus;
  productId: string;
  recentSubscriptionStartDate: Timestamp;
  signedDate: Timestamp;
}

// https://developer.apple.com/documentation/appstoreserverapi/autorenewstatus
export enum AutoRenewStatus {
  Off = 0,
  On = 1,
}

// https://developer.apple.com/documentation/appstoreserverapi/expirationintent
export enum ExpirationIntent {
  Canceled = 1,
  BillingError = 2,
  RejectedPriceIncrease = 3,
  ProductUnavailable = 4,
}

// https://developer.apple.com/documentation/appstoreserverapi/offertype
export enum OfferType {
  Introductory = 1,
  Promotional = 2,
  SubscriptionOfferCode = 3,
}

// https://developer.apple.com/documentation/appstoreserverapi/priceincreasestatus
export enum PriceIncreaseStatus {
  NoResponse = 0,
  Consented = 1,
}

// https://developer.apple.com/documentation/appstoreserverapi/orderlookupresponse
export interface OrderLookupResponse {
  orderLookupStatus: OrderLookupStatus;
  signedTransactions: JWSTransaction[];
}

// https://developer.apple.com/documentation/appstoreserverapi/orderlookupstatus
export enum OrderLookupStatus {
  Valid = 0,
  Invalid = 1,
}

// https://developer.apple.com/documentation/appstoreservernotifications/responsebodyv2decodedpayload
export interface DecodedNotificationPayload {
  notificationType: NotificationType;
  subtype?: NotificationSubtype;
  notificationUUID: string;
  version: string;
  signedDate: Timestamp;
  data: NotificationData;
}

// https://developer.apple.com/documentation/appstoreservernotifications/data
export interface NotificationData {
  appAppleId?: string;
  bundleId: string;
  bundleVersion?: number;
  environment: Environment;
  signedRenewalInfo?: JWSRenewalInfo;
  signedTransactionInfo?: JWSTransaction;
}

// https://developer.apple.com/documentation/appstoreservernotifications/notificationtype
export enum NotificationType {
  ConsumptionRequest = "CONSUMPTION_REQUEST",
  DidChangeRenewalPref = "DID_CHANGE_RENEWAL_PREF",
  DidChangeRenewalStatus = "DID_CHANGE_RENEWAL_STATUS",
  DidFailToRenew = "DID_FAIL_TO_RENEW",
  DidRenew = "DID_RENEW",
  Expired = "EXPIRED",
  GracePeriodExpired = "GRACE_PERIOD_EXPIRED",
  OfferRedeemed = "OFFER_REDEEMED",
  PriceIncrease = "PRICE_INCREASE",
  Refund = "REFUND",
  RefundDeclined = "REFUND_DECLINED",
  RenewalExtended = "RENEWAL_EXTENDED",
  Revoke = "REVOKE",
  Subscribed = "SUBSCRIBED",
  Test = "TEST",
}

// https://developer.apple.com/documentation/appstoreservernotifications/subtype
export enum NotificationSubtype {
  InitialBuy = "INITIAL_BUY",
  Resubscribe = "RESUBSCRIBE",
  Downgrade = "DOWNGRADE",
  Upgrade = "UPGRADE",
  AutoRenewEnabled = "AUTO_RENEW_ENABLED",
  AutoRenewDisabled = "AUTO_RENEW_DISABLED",
  Voluntary = "VOLUNTARY",
  BillingRetry = "BILLING_RETRY",
  PriceIncrease = "PRICE_INCREASE",
  GracePeriod = "GRACE_PERIOD",
  BillingRecovery = "BILLING_RECOVERY",
  Pending = "PENDING",
  Accepted = "ACCEPTED",
}

// https://developer.apple.com/documentation/appstoreserverapi/sendtestnotificationresponse
export interface SendTestNotificationResponse {
  testNotificationToken: string;
}

// https://developer.apple.com/documentation/appstoreserverapi/checktestnotificationresponse
export interface CheckTestNotificationResponse {
  firstSendAttemptResult: FirstSendAttemptResult;
  signedPayload: string;
}

// https://developer.apple.com/documentation/appstoreserverapi/firstsendattemptresult
export enum FirstSendAttemptResult {
  Success = "SUCCESS",
  CircularRedirect = "CIRCULAR_REDIRECT",
  InvalidResponse = "INVALID_RESPONSE",
  NoResponse = "NO_RESPONSE",
  Other = "OTHER",
  PrematureClose = "PREMATURE_CLOSE",
  SocketIssue = "SOCKET_ISSUE",
  TimedOut = "TIMED_OUT",
  TlsIssue = "TLS_ISSUE",
  UnsupportedCharset = "UNSUPPORTED_CHARSET",
}

// https://developer.apple.com/documentation/appstoreserverapi/get_notification_history
export interface NotificationHistoryQuery {
  paginationToken?: string;
}

// https://developer.apple.com/documentation/appstoreserverapi/notificationhistoryrequest
export interface NotificationHistoryRequest {
  startDate: Timestamp;
  endDate: Timestamp;
  originalTransactionId?: string;
  notificationType?: NotificationType;
  notificationSubtype?: NotificationSubtype;
}

// https://developer.apple.com/documentation/appstoreserverapi/notificationhistoryresponse
export interface NotificationHistoryResponse {
  notificationHistory: NotificationHistoryResponseItem[];
  hasMore: boolean;
  paginationToken: string;
}

// https://developer.apple.com/documentation/appstoreserverapi/notificationhistoryresponseitem
export interface NotificationHistoryResponseItem {
  firstSendAttemptResult: FirstSendAttemptResult;
  signedPayload: string;
}

export interface ResponseBodyV2 {
  signedPayload: string;
}