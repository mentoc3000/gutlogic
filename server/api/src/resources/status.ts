import { Response, Router } from "@oakserver/oak";
import log from './logger';

function status({ response }: { response: Response; }) {
  log.d("Received status ping");
  response.body = { status: "ok" };
}

const router = new Router();

router.get("/", status);

export default router;
