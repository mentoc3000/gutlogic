const start = Date.now();

import express from "express";
import * as admin from "firebase-admin";
import { urlencoded, json } from "body-parser";
import * as serviceAccount from "../firebase-adminsdk.json";
import db from "./resources/irritant_db";

const serviceAccountCamel = {
    projectId: serviceAccount.project_id,
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
};

admin.initializeApp({
    credential: admin.credential.cert(serviceAccountCamel),
});

import status from "./resources/status";
import food from "./resources/food";
import auth from "./resources/auth";
import irritant from "./resources/irritant";
import iap, { startSubscriptionRevocationCheck } from "./iap/index";
import log from './resources/logger';

const app = express();

app.use(urlencoded({ extended: false }));
app.use(json());

app.use("/", status);
app.use("/food", auth, food);
app.use("/iap", iap);
app.use("/irritant", irritant);

startSubscriptionRevocationCheck();

const port = 8080;
app.listen({ port });

const end = Date.now();

log.i(`Server loaded in ${(end - start) / 1000} seconds`);
log.i(`Listening on port ${port}`);

process.on('SIGINT', () => {
    db.close();
});