import { Response, Router } from "x/oak/mod.ts";

function status({ response }: { response: Response }) {
  response.body = { status: "ok" };
}

const router = new Router();

router.get("/", status);

export default router;
