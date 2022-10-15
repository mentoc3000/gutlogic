import test from 'ava';
import * as sinon from 'ts-sinon';
import { JWSTransactionDecodedPayload, NotificationSubtype, NotificationType } from '../src/app-store-server-api/Models';
import { AppStorePurchaseHandler, DecodedNotification, DecodedNotificationData } from '../src/iap/app-store.purchase-handler';
import { IapRepository } from '../src/iap/iap.repository';
import { createResponse, createRequest } from 'node-mocks-http';
import { productDataMap } from '../src/iap/products';
import log from '../src/resources/logger';
import express from 'express';
import bodyParser from 'body-parser';
import request from 'supertest';

var iapRepositoryStub: sinon.StubbedInstance<IapRepository>;
var handler: AppStorePurchaseHandler;

test.before(() => {
    log.mute();
});

test.beforeEach(() => {
    const iapRepository = new IapRepository(null);
    iapRepositoryStub = sinon.stubObject<IapRepository>(iapRepository);
    handler = new AppStorePurchaseHandler(iapRepositoryStub);
});

function simpleEvent(notificationType: NotificationType): DecodedNotification {
    return {
        notificationType: notificationType,
        notificationUUID: "abc123",
        version: "2.0",
        signedDate: 1664842334,
        data: null,
    };
}

function unsubscribeEvent(notificationType: NotificationType, subtype: NotificationSubtype): DecodedNotification {
    return {
        notificationType: notificationType,
        subtype: subtype,
        notificationUUID: "abc123",
        version: "2.0",
        signedDate: 1664842334,
        data: {
            transactionInfo: {
                productId: productDataMap.premium_subscription_monthly.productId,
            } as JWSTransactionDecodedPayload
        } as DecodedNotificationData
    };
}

function purchaseEvent(notificationType: NotificationType, subtype: NotificationSubtype): DecodedNotification {
    return {
        notificationType: notificationType,
        subtype: subtype,
        notificationUUID: "abc123",
        version: "2.0",
        signedDate: 1664842334,
        data: {
            transactionInfo: {
                appAccountToken: "user1234",
                purchaseDate: 166400000,
                expiresDate: 166500000,
                productId: productDataMap.premium_subscription_monthly.productId,
                originalTransactionId: "transaction5000",
                transactionId: "transaction5678",
            } as JWSTransactionDecodedPayload
        } as DecodedNotificationData
    };
}

test("ConsumptionRequest is accepted", async t => {
    const event = simpleEvent(NotificationType.ConsumptionRequest);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("DidChangeRenewalPref is accepted", async t => {
    const event = simpleEvent(NotificationType.DidChangeRenewalPref);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("DidChangeRenewalStatus is accepted", async t => {
    const event = simpleEvent(NotificationType.DidChangeRenewalStatus);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("DidFailToRenew in grace period is accepted", async t => {
    const event = unsubscribeEvent(NotificationType.DidFailToRenew, NotificationSubtype.GracePeriod);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("DidFailToRenew is accepted", async t => {
    const event = unsubscribeEvent(NotificationType.DidFailToRenew, undefined);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("DidRenew completes purchase", async t => {
    iapRepositoryStub.updatePurchase.returns(Promise.resolve());
    iapRepositoryStub.getUserIdFrom.returns(Promise.resolve('abc123'));
    const event = purchaseEvent(NotificationType.DidRenew, undefined);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("Expired is accepted", async t => {
    const event = unsubscribeEvent(NotificationType.Expired, NotificationSubtype.Voluntary);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("GracePeriodExpired is accepted", async t => {
    const event = unsubscribeEvent(NotificationType.GracePeriodExpired, undefined);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("OfferRedeemed purchases new subscription", async t => {
    iapRepositoryStub.updatePurchase.returns(Promise.resolve());
    iapRepositoryStub.getUserIdFrom.returns(Promise.resolve('abc123'));
    const event = purchaseEvent(NotificationType.OfferRedeemed, NotificationSubtype.InitialBuy);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("OfferRedeemed is accepted for active subscription", async t => {
    const event = purchaseEvent(NotificationType.OfferRedeemed, undefined);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("PriceIncrease is accepted", async t => {
    const event = simpleEvent(NotificationType.PriceIncrease);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

// test("Refund ...", async t => {
//     throw Error();
// });

test("RefundDeclined is accepted", async t => {
    const event = simpleEvent(NotificationType.RefundDeclined);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("RenewalExtended ...", async t => {
    iapRepositoryStub.updatePurchase.returns(Promise.resolve());
    iapRepositoryStub.getUserIdFrom.returns(Promise.resolve('abc123'));
    const event = purchaseEvent(NotificationType.RenewalExtended, undefined);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

// test("Revoke ...", async t => {
//     throw Error();
// });

test("Subscribed is accepted", async t => {
    iapRepositoryStub.updatePurchase.returns(Promise.resolve());
    iapRepositoryStub.getUserIdFrom.returns(Promise.resolve('abc123'));
    const event = purchaseEvent(NotificationType.Subscribed, NotificationSubtype.InitialBuy);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("Test is accepted", async t => {
    const event = simpleEvent(NotificationType.Test);
    const res = createResponse();

    await handler.handleEvent(event, res);

    t.is(res.statusCode, 200);
});

test("Handles garbage input", async t => {
    const req = createRequest();
    req.body = {
        "foo": "foo",
        "bar": "bar"
    };
    const res = createResponse();

    await handler.handleServerEvent(req, res);

    t.is(res.statusCode, 403);
});

test("Executes routed message", async t => {
    const app = express();
    app.use(bodyParser.urlencoded({ extended: false }));
    app.use(bodyParser.json());
    iapRepositoryStub.updatePurchase.returns(Promise.resolve());
    iapRepositoryStub.getUserIdFrom.returns(Promise.resolve('abc123'));
    const event = purchaseEvent(NotificationType.Subscribed, NotificationSubtype.InitialBuy);
    app.use("/", async (req, res) => {
        await handler.handleEvent(req.body, res);
    });

    const res = await request(app)
        .post('/')
        .send(event)
        .set('Accept', 'application/json');

    t.is(res.statusCode, 200);
});

test("Handles expired JWT", async t => {
    const notification = {
        "notificationType": "SUBSCRIBED",
        "subtype": "INITIAL_BUY",
        "notificationUUID": "e233457d-b5c7-4ec3-995c-60effe8c43e9",
        "data": {
            "bundleId": "com.gutlogic.app",
            "bundleVersion": "30",
            "environment": "Sandbox",
            "signedTransactionInfo": "eyJhbGciOiJFUzI1NiIsIng1YyI6WyJNSUlFTURDQ0E3YWdBd0lCQWdJUWFQb1BsZHZwU29FSDBsQnJqRFB2OWpBS0JnZ3Foa2pPUFFRREF6QjFNVVF3UWdZRFZRUURERHRCY0hCc1pTQlhiM0pzWkhkcFpHVWdSR1YyWld4dmNHVnlJRkpsYkdGMGFXOXVjeUJEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURUxNQWtHQTFVRUN3d0NSell4RXpBUkJnTlZCQW9NQ2tGd2NHeGxJRWx1WXk0eEN6QUpCZ05WQkFZVEFsVlRNQjRYRFRJeE1EZ3lOVEF5TlRBek5Gb1hEVEl6TURreU5EQXlOVEF6TTFvd2daSXhRREErQmdOVkJBTU1OMUJ5YjJRZ1JVTkRJRTFoWXlCQmNIQWdVM1J2Y21VZ1lXNWtJR2xVZFc1bGN5QlRkRzl5WlNCU1pXTmxhWEIwSUZOcFoyNXBibWN4TERBcUJnTlZCQXNNSTBGd2NHeGxJRmR2Y214a2QybGtaU0JFWlhabGJHOXdaWElnVW1Wc1lYUnBiMjV6TVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1Rc3dDUVlEVlFRR0V3SlZVekJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUFCT29UY2FQY3BlaXBOTDllUTA2dEN1N3BVY3dkQ1hkTjh2R3FhVWpkNThaOHRMeGlVQzBkQmVBK2V1TVlnZ2gxLzVpQWsrRk14VUZtQTJhMXI0YUNaOFNqZ2dJSU1JSUNCREFNQmdOVkhSTUJBZjhFQWpBQU1COEdBMVVkSXdRWU1CYUFGRDh2bENOUjAxREptaWc5N2JCODVjK2xrR0taTUhBR0NDc0dBUVVGQndFQkJHUXdZakF0QmdnckJnRUZCUWN3QW9ZaGFIUjBjRG92TDJObGNuUnpMbUZ3Y0d4bExtTnZiUzkzZDJSeVp6WXVaR1Z5TURFR0NDc0dBUVVGQnpBQmhpVm9kSFJ3T2k4dmIyTnpjQzVoY0hCc1pTNWpiMjB2YjJOemNEQXpMWGQzWkhKbk5qQXlNSUlCSGdZRFZSMGdCSUlCRlRDQ0FSRXdnZ0VOQmdvcWhraUc5Mk5rQlFZQk1JSCtNSUhEQmdnckJnRUZCUWNDQWpDQnRneUJzMUpsYkdsaGJtTmxJRzl1SUhSb2FYTWdZMlZ5ZEdsbWFXTmhkR1VnWW5rZ1lXNTVJSEJoY25SNUlHRnpjM1Z0WlhNZ1lXTmpaWEIwWVc1alpTQnZaaUIwYUdVZ2RHaGxiaUJoY0hCc2FXTmhZbXhsSUhOMFlXNWtZWEprSUhSbGNtMXpJR0Z1WkNCamIyNWthWFJwYjI1eklHOW1JSFZ6WlN3Z1kyVnlkR2xtYVdOaGRHVWdjRzlzYVdONUlHRnVaQ0JqWlhKMGFXWnBZMkYwYVc5dUlIQnlZV04wYVdObElITjBZWFJsYldWdWRITXVNRFlHQ0NzR0FRVUZCd0lCRmlwb2RIUndPaTh2ZDNkM0xtRndjR3hsTG1OdmJTOWpaWEowYVdacFkyRjBaV0YxZEdodmNtbDBlUzh3SFFZRFZSME9CQllFRkNPQ21NQnEvLzFMNWltdlZtcVgxb0NZZXFyTU1BNEdBMVVkRHdFQi93UUVBd0lIZ0RBUUJnb3Foa2lHOTJOa0Jnc0JCQUlGQURBS0JnZ3Foa2pPUFFRREF3Tm9BREJsQWpFQWw0SkI5R0pIaXhQMm51aWJ5VTFrM3dyaTVwc0dJeFBNRTA1c0ZLcTdoUXV6dmJleUJ1ODJGb3p6eG1ienBvZ29BakJMU0ZsMGRaV0lZbDJlalBWK0RpNWZCbktQdThteW1CUXRvRS9IMmJFUzBxQXM4Yk51ZVUzQ0JqamgxbHduRHNJPSIsIk1JSURGakNDQXB5Z0F3SUJBZ0lVSXNHaFJ3cDBjMm52VTRZU3ljYWZQVGp6Yk5jd0NnWUlLb1pJemowRUF3TXdaekViTUJrR0ExVUVBd3dTUVhCd2JHVWdVbTl2ZENCRFFTQXRJRWN6TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd0hoY05NakV3TXpFM01qQXpOekV3V2hjTk16WXdNekU1TURBd01EQXdXakIxTVVRd1FnWURWUVFERER0QmNIQnNaU0JYYjNKc1pIZHBaR1VnUkdWMlpXeHZjR1Z5SUZKbGJHRjBhVzl1Y3lCRFpYSjBhV1pwWTJGMGFXOXVJRUYxZEdodmNtbDBlVEVMTUFrR0ExVUVDd3dDUnpZeEV6QVJCZ05WQkFvTUNrRndjR3hsSUVsdVl5NHhDekFKQmdOVkJBWVRBbFZUTUhZd0VBWUhLb1pJemowQ0FRWUZLNEVFQUNJRFlnQUVic1FLQzk0UHJsV21aWG5YZ3R4emRWSkw4VDBTR1luZ0RSR3BuZ24zTjZQVDhKTUViN0ZEaTRiQm1QaENuWjMvc3E2UEYvY0djS1hXc0w1dk90ZVJoeUo0NXgzQVNQN2NPQithYW85MGZjcHhTdi9FWkZibmlBYk5nWkdoSWhwSW80SDZNSUgzTUJJR0ExVWRFd0VCL3dRSU1BWUJBZjhDQVFBd0h3WURWUjBqQkJnd0ZvQVV1N0Rlb1ZnemlKcWtpcG5ldnIzcnI5ckxKS3N3UmdZSUt3WUJCUVVIQVFFRU9qQTRNRFlHQ0NzR0FRVUZCekFCaGlwb2RIUndPaTh2YjJOemNDNWhjSEJzWlM1amIyMHZiMk56Y0RBekxXRndjR3hsY205dmRHTmhaek13TndZRFZSMGZCREF3TGpBc29DcWdLSVltYUhSMGNEb3ZMMk55YkM1aGNIQnNaUzVqYjIwdllYQndiR1Z5YjI5MFkyRm5NeTVqY213d0hRWURWUjBPQkJZRUZEOHZsQ05SMDFESm1pZzk3YkI4NWMrbGtHS1pNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVFCZ29xaGtpRzkyTmtCZ0lCQkFJRkFEQUtCZ2dxaGtqT1BRUURBd05vQURCbEFqQkFYaFNxNUl5S29nTUNQdHc0OTBCYUI2NzdDYUVHSlh1ZlFCL0VxWkdkNkNTamlDdE9udU1UYlhWWG14eGN4ZmtDTVFEVFNQeGFyWlh2TnJreFUzVGtVTUkzM3l6dkZWVlJUNHd4V0pDOTk0T3NkY1o0K1JHTnNZRHlSNWdtZHIwbkRHZz0iLCJNSUlDUXpDQ0FjbWdBd0lCQWdJSUxjWDhpTkxGUzVVd0NnWUlLb1pJemowRUF3TXdaekViTUJrR0ExVUVBd3dTUVhCd2JHVWdVbTl2ZENCRFFTQXRJRWN6TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd0hoY05NVFF3TkRNd01UZ3hPVEEyV2hjTk16a3dORE13TVRneE9UQTJXakJuTVJzd0dRWURWUVFEREJKQmNIQnNaU0JTYjI5MElFTkJJQzBnUnpNeEpqQWtCZ05WQkFzTUhVRndjR3hsSUVObGNuUnBabWxqWVhScGIyNGdRWFYwYUc5eWFYUjVNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVFzd0NRWURWUVFHRXdKVlV6QjJNQkFHQnlxR1NNNDlBZ0VHQlN1QkJBQWlBMklBQkpqcEx6MUFjcVR0a3lKeWdSTWMzUkNWOGNXalRuSGNGQmJaRHVXbUJTcDNaSHRmVGpqVHV4eEV0WC8xSDdZeVlsM0o2WVJiVHpCUEVWb0EvVmhZREtYMUR5eE5CMGNUZGRxWGw1ZHZNVnp0SzUxN0lEdll1VlRaWHBta09sRUtNYU5DTUVBd0hRWURWUjBPQkJZRUZMdXczcUZZTTRpYXBJcVozcjY5NjYvYXl5U3JNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdEZ1lEVlIwUEFRSC9CQVFEQWdFR01Bb0dDQ3FHU000OUJBTURBMmdBTUdVQ01RQ0Q2Y0hFRmw0YVhUUVkyZTN2OUd3T0FFWkx1Tit5UmhIRkQvM21lb3locG12T3dnUFVuUFdUeG5TNGF0K3FJeFVDTUcxbWloREsxQTNVVDgyTlF6NjBpbU9sTTI3amJkb1h0MlFmeUZNbStZaGlkRGtMRjF2TFVhZ002QmdENTZLeUtBPT0iXX0.eyJ0cmFuc2FjdGlvbklkIjoiMjAwMDAwMDE2ODA3Mzg0MCIsIm9yaWdpbmFsVHJhbnNhY3Rpb25JZCI6IjIwMDAwMDAxNjgwNzM4NDAiLCJ3ZWJPcmRlckxpbmVJdGVtSWQiOiIyMDAwMDAwMDEyMDcyOTY5IiwiYnVuZGxlSWQiOiJjb20uZ3V0bG9naWMuYXBwIiwicHJvZHVjdElkIjoicHJlbWl1bV9zdWJzY3JpcHRpb25fbW9udGhseSIsInN1YnNjcmlwdGlvbkdyb3VwSWRlbnRpZmllciI6IjIxMDEzNTYxIiwicHVyY2hhc2VEYXRlIjoxNjY0NzU2NDA2MDAwLCJvcmlnaW5hbFB1cmNoYXNlRGF0ZSI6MTY2NDc1NjQwNzAwMCwiZXhwaXJlc0RhdGUiOjE2NjQ3NTY3MDYwMDAsInF1YW50aXR5IjoxLCJ0eXBlIjoiQXV0by1SZW5ld2FibGUgU3Vic2NyaXB0aW9uIiwiaW5BcHBPd25lcnNoaXBUeXBlIjoiUFVSQ0hBU0VEIiwic2lnbmVkRGF0ZSI6MTY2NDc1NjQxMjc5OCwiZW52aXJvbm1lbnQiOiJTYW5kYm94In0.Sy4snL1SMpAwNOk35DfVyrG4nMhkcMUNcoN1yg6WhKNZVGlO-wvpN4ali-bzQs183gSn-s3Qx9nI2djdQSn9Yw",
            "signedRenewalInfo": "eyJhbGciOiJFUzI1NiIsIng1YyI6WyJNSUlFTURDQ0E3YWdBd0lCQWdJUWFQb1BsZHZwU29FSDBsQnJqRFB2OWpBS0JnZ3Foa2pPUFFRREF6QjFNVVF3UWdZRFZRUURERHRCY0hCc1pTQlhiM0pzWkhkcFpHVWdSR1YyWld4dmNHVnlJRkpsYkdGMGFXOXVjeUJEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURUxNQWtHQTFVRUN3d0NSell4RXpBUkJnTlZCQW9NQ2tGd2NHeGxJRWx1WXk0eEN6QUpCZ05WQkFZVEFsVlRNQjRYRFRJeE1EZ3lOVEF5TlRBek5Gb1hEVEl6TURreU5EQXlOVEF6TTFvd2daSXhRREErQmdOVkJBTU1OMUJ5YjJRZ1JVTkRJRTFoWXlCQmNIQWdVM1J2Y21VZ1lXNWtJR2xVZFc1bGN5QlRkRzl5WlNCU1pXTmxhWEIwSUZOcFoyNXBibWN4TERBcUJnTlZCQXNNSTBGd2NHeGxJRmR2Y214a2QybGtaU0JFWlhabGJHOXdaWElnVW1Wc1lYUnBiMjV6TVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1Rc3dDUVlEVlFRR0V3SlZVekJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUFCT29UY2FQY3BlaXBOTDllUTA2dEN1N3BVY3dkQ1hkTjh2R3FhVWpkNThaOHRMeGlVQzBkQmVBK2V1TVlnZ2gxLzVpQWsrRk14VUZtQTJhMXI0YUNaOFNqZ2dJSU1JSUNCREFNQmdOVkhSTUJBZjhFQWpBQU1COEdBMVVkSXdRWU1CYUFGRDh2bENOUjAxREptaWc5N2JCODVjK2xrR0taTUhBR0NDc0dBUVVGQndFQkJHUXdZakF0QmdnckJnRUZCUWN3QW9ZaGFIUjBjRG92TDJObGNuUnpMbUZ3Y0d4bExtTnZiUzkzZDJSeVp6WXVaR1Z5TURFR0NDc0dBUVVGQnpBQmhpVm9kSFJ3T2k4dmIyTnpjQzVoY0hCc1pTNWpiMjB2YjJOemNEQXpMWGQzWkhKbk5qQXlNSUlCSGdZRFZSMGdCSUlCRlRDQ0FSRXdnZ0VOQmdvcWhraUc5Mk5rQlFZQk1JSCtNSUhEQmdnckJnRUZCUWNDQWpDQnRneUJzMUpsYkdsaGJtTmxJRzl1SUhSb2FYTWdZMlZ5ZEdsbWFXTmhkR1VnWW5rZ1lXNTVJSEJoY25SNUlHRnpjM1Z0WlhNZ1lXTmpaWEIwWVc1alpTQnZaaUIwYUdVZ2RHaGxiaUJoY0hCc2FXTmhZbXhsSUhOMFlXNWtZWEprSUhSbGNtMXpJR0Z1WkNCamIyNWthWFJwYjI1eklHOW1JSFZ6WlN3Z1kyVnlkR2xtYVdOaGRHVWdjRzlzYVdONUlHRnVaQ0JqWlhKMGFXWnBZMkYwYVc5dUlIQnlZV04wYVdObElITjBZWFJsYldWdWRITXVNRFlHQ0NzR0FRVUZCd0lCRmlwb2RIUndPaTh2ZDNkM0xtRndjR3hsTG1OdmJTOWpaWEowYVdacFkyRjBaV0YxZEdodmNtbDBlUzh3SFFZRFZSME9CQllFRkNPQ21NQnEvLzFMNWltdlZtcVgxb0NZZXFyTU1BNEdBMVVkRHdFQi93UUVBd0lIZ0RBUUJnb3Foa2lHOTJOa0Jnc0JCQUlGQURBS0JnZ3Foa2pPUFFRREF3Tm9BREJsQWpFQWw0SkI5R0pIaXhQMm51aWJ5VTFrM3dyaTVwc0dJeFBNRTA1c0ZLcTdoUXV6dmJleUJ1ODJGb3p6eG1ienBvZ29BakJMU0ZsMGRaV0lZbDJlalBWK0RpNWZCbktQdThteW1CUXRvRS9IMmJFUzBxQXM4Yk51ZVUzQ0JqamgxbHduRHNJPSIsIk1JSURGakNDQXB5Z0F3SUJBZ0lVSXNHaFJ3cDBjMm52VTRZU3ljYWZQVGp6Yk5jd0NnWUlLb1pJemowRUF3TXdaekViTUJrR0ExVUVBd3dTUVhCd2JHVWdVbTl2ZENCRFFTQXRJRWN6TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd0hoY05NakV3TXpFM01qQXpOekV3V2hjTk16WXdNekU1TURBd01EQXdXakIxTVVRd1FnWURWUVFERER0QmNIQnNaU0JYYjNKc1pIZHBaR1VnUkdWMlpXeHZjR1Z5SUZKbGJHRjBhVzl1Y3lCRFpYSjBhV1pwWTJGMGFXOXVJRUYxZEdodmNtbDBlVEVMTUFrR0ExVUVDd3dDUnpZeEV6QVJCZ05WQkFvTUNrRndjR3hsSUVsdVl5NHhDekFKQmdOVkJBWVRBbFZUTUhZd0VBWUhLb1pJemowQ0FRWUZLNEVFQUNJRFlnQUVic1FLQzk0UHJsV21aWG5YZ3R4emRWSkw4VDBTR1luZ0RSR3BuZ24zTjZQVDhKTUViN0ZEaTRiQm1QaENuWjMvc3E2UEYvY0djS1hXc0w1dk90ZVJoeUo0NXgzQVNQN2NPQithYW85MGZjcHhTdi9FWkZibmlBYk5nWkdoSWhwSW80SDZNSUgzTUJJR0ExVWRFd0VCL3dRSU1BWUJBZjhDQVFBd0h3WURWUjBqQkJnd0ZvQVV1N0Rlb1ZnemlKcWtpcG5ldnIzcnI5ckxKS3N3UmdZSUt3WUJCUVVIQVFFRU9qQTRNRFlHQ0NzR0FRVUZCekFCaGlwb2RIUndPaTh2YjJOemNDNWhjSEJzWlM1amIyMHZiMk56Y0RBekxXRndjR3hsY205dmRHTmhaek13TndZRFZSMGZCREF3TGpBc29DcWdLSVltYUhSMGNEb3ZMMk55YkM1aGNIQnNaUzVqYjIwdllYQndiR1Z5YjI5MFkyRm5NeTVqY213d0hRWURWUjBPQkJZRUZEOHZsQ05SMDFESm1pZzk3YkI4NWMrbGtHS1pNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVFCZ29xaGtpRzkyTmtCZ0lCQkFJRkFEQUtCZ2dxaGtqT1BRUURBd05vQURCbEFqQkFYaFNxNUl5S29nTUNQdHc0OTBCYUI2NzdDYUVHSlh1ZlFCL0VxWkdkNkNTamlDdE9udU1UYlhWWG14eGN4ZmtDTVFEVFNQeGFyWlh2TnJreFUzVGtVTUkzM3l6dkZWVlJUNHd4V0pDOTk0T3NkY1o0K1JHTnNZRHlSNWdtZHIwbkRHZz0iLCJNSUlDUXpDQ0FjbWdBd0lCQWdJSUxjWDhpTkxGUzVVd0NnWUlLb1pJemowRUF3TXdaekViTUJrR0ExVUVBd3dTUVhCd2JHVWdVbTl2ZENCRFFTQXRJRWN6TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd0hoY05NVFF3TkRNd01UZ3hPVEEyV2hjTk16a3dORE13TVRneE9UQTJXakJuTVJzd0dRWURWUVFEREJKQmNIQnNaU0JTYjI5MElFTkJJQzBnUnpNeEpqQWtCZ05WQkFzTUhVRndjR3hsSUVObGNuUnBabWxqWVhScGIyNGdRWFYwYUc5eWFYUjVNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVFzd0NRWURWUVFHRXdKVlV6QjJNQkFHQnlxR1NNNDlBZ0VHQlN1QkJBQWlBMklBQkpqcEx6MUFjcVR0a3lKeWdSTWMzUkNWOGNXalRuSGNGQmJaRHVXbUJTcDNaSHRmVGpqVHV4eEV0WC8xSDdZeVlsM0o2WVJiVHpCUEVWb0EvVmhZREtYMUR5eE5CMGNUZGRxWGw1ZHZNVnp0SzUxN0lEdll1VlRaWHBta09sRUtNYU5DTUVBd0hRWURWUjBPQkJZRUZMdXczcUZZTTRpYXBJcVozcjY5NjYvYXl5U3JNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdEZ1lEVlIwUEFRSC9CQVFEQWdFR01Bb0dDQ3FHU000OUJBTURBMmdBTUdVQ01RQ0Q2Y0hFRmw0YVhUUVkyZTN2OUd3T0FFWkx1Tit5UmhIRkQvM21lb3locG12T3dnUFVuUFdUeG5TNGF0K3FJeFVDTUcxbWloREsxQTNVVDgyTlF6NjBpbU9sTTI3amJkb1h0MlFmeUZNbStZaGlkRGtMRjF2TFVhZ002QmdENTZLeUtBPT0iXX0.eyJvcmlnaW5hbFRyYW5zYWN0aW9uSWQiOiIyMDAwMDAwMTY4MDczODQwIiwiYXV0b1JlbmV3UHJvZHVjdElkIjoicHJlbWl1bV9zdWJzY3JpcHRpb25fbW9udGhseSIsInByb2R1Y3RJZCI6InByZW1pdW1fc3Vic2NyaXB0aW9uX21vbnRobHkiLCJhdXRvUmVuZXdTdGF0dXMiOjEsInNpZ25lZERhdGUiOjE2NjQ3NTY0MTI3NzksImVudmlyb25tZW50IjoiU2FuZGJveCIsInJlY2VudFN1YnNjcmlwdGlvblN0YXJ0RGF0ZSI6MTY2NDc1NjQwNjAwMH0.HucBMJieVoyZQuNE35sKV9NtQJqLLQAylNnjUsoPl4-X14jVhnoTzyzY5ST0o49HK1r-2kXXLAgmZYu8gxODmA"
        },
        "version": "2.0",
        "signedDate": 1664756412795
    };

    const req = createRequest();
    req.body = notification;
    const res = createResponse();

    await handler.handleServerEvent(req, res);

    t.is(res.statusCode, 403);

});
