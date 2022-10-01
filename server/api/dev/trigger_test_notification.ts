import { readFileSync } from "fs";
import * as jose from "jose";
import axios, { AxiosError } from "axios";

const useSandbox = true;

const header = {
    "alg": "ES256",
    "kid": "7K2G375XP3",
    "typ": "JWT"
};

const payload = {
    "bid": "com.gutlogic.app"
};

const pkcs8 = readFileSync(`dev/SubscriptionKey_${header.kid}.p8`).toString();

async function getJwt(privateKey: jose.KeyLike): Promise<string> {
    const jwt = new jose.SignJWT(payload)
        .setProtectedHeader(header)
        .setIssuedAt()
        .setIssuer('9fd8aa47-a866-4f2d-b5c5-90e44847c4ca')
        .setAudience('appstoreconnect-v1')
        .setExpirationTime('5m');
    return await jwt.sign(privateKey);
}

(async () => {
    const privateKey = await jose.importPKCS8(pkcs8, header.alg);

    console.log("Requesting test notification");
    const configSend = { headers: { "Authorization": `Bearer ${await getJwt(privateKey)}` } };

    const urlRequest = useSandbox
        ? "https://api.storekit-sandbox.itunes.apple.com/inApps/v1/notifications/test"
        : "https://api.storekit.itunes.apple.com/inApps/v1/notifications/test";
    const resSend = await axios.post<{ testNotificationToken: string; }>(urlRequest, null, configSend);
    const { testNotificationToken } = resSend.data;
    console.log(`Test notification token: ${testNotificationToken}`);

    process.stdout.write("Waiting");
    const waitTime = 5;
    const waitFunc = (resolve: (value: unknown) => void) => setTimeout(resolve, 1000);
    for (var i = 0; i < waitTime; i++) {
        // eslint-disable-next-line no-await-in-loop
        await new Promise(waitFunc);
        process.stdout.write(".");
    }
    process.stdout.write("\n");

    console.log("Getting test notification status");
    const urlGet = useSandbox
        ? `https://api.storekit-sandbox.itunes.apple.com/inApps/v1/notifications/test/${testNotificationToken}`
        : `https://api.storekit.itunes.apple.com/inApps/v1/notifications/test/${testNotificationToken}`;
    const configGet = { headers: { "Authorization": `Bearer ${await getJwt(privateKey)}` } };
    const resGet = await axios.get<{ firstSendAttemptResult: string; signedPayload: string; }>(urlGet, configGet);
    const { firstSendAttemptResult, signedPayload } = resGet.data;
    console.log(`First send attempt result: ${firstSendAttemptResult}`);
    // console.log(`Signed payload: ${signedPayload}`);
})().catch(e => {
    if (e instanceof AxiosError) {
        console.log(`Status ${e.response.status}: ${JSON.stringify(e.response.data)}`);
    } else {
        console.log(e);
    }
});