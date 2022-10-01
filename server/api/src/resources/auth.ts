import { Request, Response, NextFunction } from "express";
import { getAuth } from 'firebase-admin/auth';
import * as config from "../config.json";
import log from "./logger";


const validateJwt = async (jwt: string): Promise<boolean> => {
  const projectId = config.projectId;
  try {
    const decodedToken = await getAuth().verifyIdToken(jwt);
    // TODO: verify contents
  } catch {
    return false;
  }

  return true;
};

const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  // Taking JWT from Authorization header and comparing if it is valid JWT token, if YES - we continue,
  // otherwise we return with status code 401
  const authorization = req.header("Authorization");
  if (!authorization) {
    res.status(401).json({ message: "Missing authorization header" });
    return;
  }

  const jwt = authorization.split(" ")[1];
  if (!jwt) {
    res.status(401).json({ message: "Malformed jwt token" });
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
