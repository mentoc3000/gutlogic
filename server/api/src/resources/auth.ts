import { Request, Response, NextFunction } from "express";
import { getAuth } from "firebase-admin/auth";
import log from "./logger";


const validateJwt = async (jwt: string): Promise<boolean> => {
  try {
    await getAuth().verifyIdToken(jwt);
  } catch (e) {
    log.d(`Invalid jwt token ${jwt}: ${JSON.stringify(e, Object.getOwnPropertyNames(e))}`);
    return false;
  }

  return true;
};

const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  // Taking JWT from Authorization header and comparing if it is valid JWT token, if YES - we continue,
  // otherwise we return with status code 401
  const authorization = req.header("Authorization");
  if (!authorization) {
    log.d("Missing authorization header");
    res.status(401).json({ message: "Missing authorization header" });
    return;
  }

  const jwt = authorization.split(" ")[1];
  if (!jwt) {
    log.d(`Malformed authorization header: ${authorization}`);
    res.status(401).json({ message: "Malformed authorization header" });
    return;
  }

  if (await validateJwt(jwt)) {
    // eslint-disable-next-line callback-return
    next();
  } else {
    res.status(401).json({ message: "Invalid jwt token" });
  }
};

export default authMiddleware;
