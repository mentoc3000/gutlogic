import express from "express";

import status from "./resources/status";
import food from "./resources/food";
import auth from "./resources/auth";
import log from './resources/logger';

const app = express();

app.use("/", status);
app.use("/food", auth, food);

const port = 8080;
app.listen({ port });

log.i(`Listening on port ${port}`);
