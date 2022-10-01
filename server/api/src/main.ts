import express from "express";
import * as admin from "firebase-admin";
import * as bodyParser from "body-parser";

admin.initializeApp();

import status from "./resources/status";
import food from "./resources/food";
import auth from "./resources/auth";
import iap, { startSubscriptionRevocationCheck } from "./iap/index";
import log from './resources/logger';

const app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use("/", status);
app.use("/food", auth, food);
app.use("/iap", iap);

startSubscriptionRevocationCheck();

const port = 8080;
app.listen({ port });

log.i(`Listening on port ${port}`);
