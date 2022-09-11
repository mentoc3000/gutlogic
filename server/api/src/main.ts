import { Application, Router } from "@oakserver/oak";

import status from "./resources/status";
import food, { startEdamamHeartbeat } from "./resources/food";
import auth from "./resources/auth";

const router = new Router();

router.use("/", status.routes(), status.allowedMethods());
router.use("/food", auth, food.routes(), food.allowedMethods());

const app = new Application();

app.use(router.routes());
app.use(router.allowedMethods());

startEdamamHeartbeat();

app.listen({ port: 8080 });
