import express, { Response } from "express";
import log from "./logger";

function status({ req, res }: { req: Request, res: Response; }) {
  log.d("Received status ping");
  res.json({ status: "ok" });
}

const router = express.Router();

router.get("/", status);

export default router;
