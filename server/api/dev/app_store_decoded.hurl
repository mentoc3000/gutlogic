POST http://localhost:8080/iap/test
{
    "notificationType": "SUBSCRIBED",
    "subtype": "INITIAL_BUY",
    "notificationUUID": "abc123",
    "version": "2.0",
    "signedDate": 1664842334,
    "data": {
        "transactionInfo": {
            "appAccountToken": "user1234",
            "expiresDate": 166500000,
            "productId": "premium_subscription_monthly",
            "transactionId": "transaction5678"
        }
    }
}

HTTP/1.1 200