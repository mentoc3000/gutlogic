import { Application, Router } from "x/oak/mod.ts";

import status from "/resources/status.ts";
import food from "/resources/food.ts";
import auth from "/resources/auth.ts";

const router = new Router();

router.use("/", status.routes(), status.allowedMethods());
router.use("/food", auth, food.routes(), food.allowedMethods());

const app = new Application();

app.use(router.routes());
app.use(router.allowedMethods());

await app.listen({ port: 8080 });
