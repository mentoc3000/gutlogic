"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GooglePlayPurchaseHandler = void 0;
var purchase_handler_1 = require("./purchase-handler");
var products_1 = require("./products");
var config_json_1 = require("../config.json");
var google_auth_library_1 = require("google-auth-library");
var googleapis_1 = require("googleapis");
var google_play_console_cloud_functions_key_json_1 = __importDefault(require("./google_play_console_cloud_functions_key.json"));
var firestore_1 = require("firebase-admin/firestore");
var GooglePlayPurchaseHandler = /** @class */ (function (_super) {
    __extends(GooglePlayPurchaseHandler, _super);
    function GooglePlayPurchaseHandler(iapRepository) {
        var _this = _super.call(this) || this;
        _this.iapRepository = iapRepository;
        _this.handleServerEvent = function (message) { return __awaiter(_this, void 0, void 0, function () {
            var event, _a, purchaseToken, subscriptionId, sku, productData, notificationType, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        // Parse the event data
                        try {
                            event = JSON.parse(new Buffer(message.data, "base64").toString("ascii"));
                        }
                        catch (e) {
                            console.error("Could not parse Google Play billing event", e);
                            return [2 /*return*/];
                        }
                        // Skip test events
                        if (event.testNotification)
                            return [2 /*return*/];
                        _a = __assign(__assign({}, event.subscriptionNotification), event.oneTimeProductNotification), purchaseToken = _a.purchaseToken, subscriptionId = _a.subscriptionId, sku = _a.sku;
                        productData = products_1.productDataMap[subscriptionId !== null && subscriptionId !== void 0 ? subscriptionId : sku];
                        // Skip products that are unknown
                        if (!productData)
                            return [2 /*return*/];
                        notificationType = subscriptionId ? "SUBSCRIPTION" : null;
                        if (productData.type !== notificationType)
                            return [2 /*return*/];
                        _b = notificationType;
                        switch (_b) {
                            case "SUBSCRIPTION": return [3 /*break*/, 1];
                        }
                        return [3 /*break*/, 3];
                    case 1: return [4 /*yield*/, this.handleSubscription(null, productData, purchaseToken)];
                    case 2:
                        _c.sent();
                        return [3 /*break*/, 3];
                    case 3: return [2 /*return*/];
                }
            });
        }); };
        _this.androidPublisher = new googleapis_1.androidpublisher_v3.Androidpublisher({
            auth: new google_auth_library_1.GoogleAuth({
                credentials: google_play_console_cloud_functions_key_json_1.default,
                scopes: ["https://www.googleapis.com/auth/androidpublisher"],
            }),
        });
        return _this;
    }
    GooglePlayPurchaseHandler.prototype.handleSubscription = function (userId, productData, token) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var response, orderId, orderIdMatch, purchaseLog, e_1, e_2;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        _d.trys.push([0, 9, , 10]);
                        return [4 /*yield*/, this.androidPublisher.purchases.subscriptions.get({
                                packageName: config_json_1.packageName,
                                subscriptionId: productData.productId,
                                token: token,
                            })];
                    case 1:
                        response = _d.sent();
                        if (!response.data.orderId) {
                            console.error("Could not handle purchase without order id");
                            return [2 /*return*/, false];
                        }
                        orderId = response.data.orderId;
                        orderIdMatch = /^(.+)?[.]{2}[0-9]+$/g.exec(orderId);
                        if (orderIdMatch) {
                            orderId = orderIdMatch[1];
                        }
                        console.log({
                            rawOrderId: response.data.orderId,
                            newOrderId: orderId,
                        });
                        purchaseLog = {
                            premiumIapSource: "google_play",
                            premiumOrderId: orderId,
                            premiumPurchaseDate: firestore_1.Timestamp.fromMillis(parseInt((_a = response.data.startTimeMillis) !== null && _a !== void 0 ? _a : "0", 10)),
                            premiumExpirationDate: firestore_1.Timestamp.fromMillis(parseInt((_b = response.data.expiryTimeMillis) !== null && _b !== void 0 ? _b : "0", 10)),
                            premiumStatus: [
                                "PENDING",
                                "ACTIVE",
                                "ACTIVE",
                                "PENDING",
                                "EXPIRED", // Expired or cancelled
                            ][(_c = response.data.paymentState) !== null && _c !== void 0 ? _c : 4],
                        };
                        _d.label = 2;
                    case 2:
                        _d.trys.push([2, 7, , 8]);
                        if (!userId) return [3 /*break*/, 4];
                        // If we know the userId,
                        // update the existing purchase or create it if it does not exist.
                        return [4 /*yield*/, this.iapRepository.createOrUpdatePurchase({ userId: userId, purchaseLog: purchaseLog })];
                    case 3:
                        // If we know the userId,
                        // update the existing purchase or create it if it does not exist.
                        _d.sent();
                        return [3 /*break*/, 6];
                    case 4: 
                    // If we do not know the user id, a previous entry must already
                    // exist, and thus we'll only update it.
                    return [4 /*yield*/, this.iapRepository.updatePurchase({ purchaseLog: purchaseLog })];
                    case 5:
                        // If we do not know the user id, a previous entry must already
                        // exist, and thus we'll only update it.
                        _d.sent();
                        _d.label = 6;
                    case 6: return [3 /*break*/, 8];
                    case 7:
                        e_1 = _d.sent();
                        console.log("Could not create or update purchase", { orderId: orderId, productId: productData.productId });
                        console.error(e_1);
                        return [3 /*break*/, 8];
                    case 8: return [2 /*return*/, true];
                    case 9:
                        e_2 = _d.sent();
                        console.error(e_2);
                        return [2 /*return*/, false];
                    case 10: return [2 /*return*/];
                }
            });
        });
    };
    return GooglePlayPurchaseHandler;
}(purchase_handler_1.PurchaseHandler));
exports.GooglePlayPurchaseHandler = GooglePlayPurchaseHandler;
