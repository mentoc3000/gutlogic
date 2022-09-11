import { Context } from "@oakserver/oak";
import { FlattenedJWSInput, importX509, JWSHeaderParameters, jwtVerify, KeyLike } from "jose";
import * as config from "../config.json";
import log from "./logger";


class JWKSNoMatchingKey extends Error {
  constructor() {
    super();

    // assign the error class name in your custom error (as a shortcut)
    this.name = this.constructor.name;

    // capturing the stack trace keeps the reference to your error class
    Error.captureStackTrace(this, this.constructor);
  }
}



class JWKSTimeout extends Error {
  constructor() {
    super();

    // assign the error class name in your custom error (as a shortcut)
    this.name = this.constructor.name;

    // capturing the stack trace keeps the reference to your error class
    Error.captureStackTrace(this, this.constructor);
  }
}


class JWKSError extends Error {
  constructor(message: string) {
    super(message);

    // assign the error class name in your custom error (as a shortcut)
    this.name = this.constructor.name;

    // capturing the stack trace keeps the reference to your error class
    Error.captureStackTrace(this, this.constructor);
  }
}

/*
The code below was drawn in part from the deno package jose
https://github.com/panva/jose

The MIT License (MIT)

Copyright (c) 2018 Filip Skokan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
class RemoteKeySet {
  private _url: globalThis.URL;

  /**
   * Timeout (in milliseconds) for the HTTP request. When reached the request
   * will be aborted and the verification will fail. Default is 5000 (5
   * seconds).
   */
  private _timeoutDuration = 5000;

  /**
   * Duration (in milliseconds) for which no more HTTP requests will be
   * triggered after a previous successful fetch. Default is 30000 (30 seconds).
   */
  private _cooldownDuration = 30000;

  /**
   * Maximum time (in milliseconds) between successful HTTP requests. Default is
   * 600000 (10 minutes).
   */
  private _cacheMaxAge = 600000;

  private _algorithm: string;

  private _keysTimestamp?: number;

  private _pendingFetch?: Promise<void>;

  private _keysCache?: Map<string, KeyLike>;

  constructor(url: URL) {
    this._keysCache = undefined;
    this._url = new URL(url.href);
    this._algorithm = "RS256";
  }

  coolingDown() {
    return typeof this._keysTimestamp === "number"
      ? Date.now() < this._keysTimestamp + this._cooldownDuration
      : false;
  }

  fresh() {
    return typeof this._keysTimestamp === "number"
      ? Date.now() < this._keysTimestamp + this._cacheMaxAge
      : false;
  }

  async getKey(
    protectedHeader: JWSHeaderParameters,
    token: FlattenedJWSInput,
  ): Promise<KeyLike> {
    if (!this._keysCache || !this.fresh()) {
      await this.reload();
    }

    try {
      return await this.getCachedKey(protectedHeader, token);
    } catch (err) {
      if (err instanceof JWKSNoMatchingKey) {
        if (this.coolingDown() === false) {
          await this.reload();
          return this.getCachedKey(protectedHeader, token);
        }
      }
      throw err;
    }
  }

  private async getCachedKey(
    protectedHeader: JWSHeaderParameters,
    token: FlattenedJWSInput,
  ): Promise<KeyLike> {
    const { kid } = { ...protectedHeader, ...token.header };

    if (kid && this._keysCache?.has(kid)) {
      return this._keysCache.get(kid)!;
    }

    throw new JWKSNoMatchingKey();
  }

  async reload() {
    if (!this._pendingFetch) {
      this._pendingFetch = fetchKeys(
        this._url,
        this._timeoutDuration,
      )
        .then((x509s: Map<string, string>) => {
          return Promise.all(
            Array.from(x509s.entries()).map(async (
              entry,
            ) => [entry[0], await importX509(entry[1], this._algorithm)]),
          );
        })
        .then((keys: (string | KeyLike)[][]) => {
          this._keysCache = new Map(keys as [string, KeyLike][]);
          this._keysTimestamp = Date.now();
          this._pendingFetch = undefined;
          return null;
        })
        .catch((err: Error) => {
          this._pendingFetch = undefined;
          throw err;
        });
    }

    await this._pendingFetch;
  }
}

async function fetchKeys(
  url: URL,
  timeout: number,
): Promise<Map<string, string>> {
  log.i("Fetching new Firestore keys");

  let controller!: AbortController;
  let id!: ReturnType<typeof setTimeout>;
  let timedOut = false;
  if (typeof AbortController === "function") {
    controller = new AbortController();
    id = setTimeout(() => {
      timedOut = true;
      controller.abort();
    }, timeout);
  }

  const response = await fetch(url.href, {
    signal: controller ? controller.signal : undefined,
    redirect: "manual",
  }).catch((err) => {
    if (timedOut) throw new JWKSTimeout();
    throw err;
  });

  if (id !== undefined) clearTimeout(id);

  if (response.status !== 200) {
    throw new JWKSError(
      "Expected 200 OK from the JSON Web Key Set HTTP response",
    );
  }

  try {
    const text = await response.text();
    const json = JSON.parse(text);
    return new Map(Object.entries(json));
  } catch {
    throw new JWKSError(
      "Failed to parse the Key Set HTTP response as Map",
    );
  }
}

function createRemoteKeySet(url: URL): KeyLike {
  return RemoteKeySet.prototype.getKey.bind(new RemoteKeySet(url));
}

// End of code from jose

// Get Firebase auth keys from Google
const getKey = createRemoteKeySet(
  new URL(
    "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com",
  ),
);

const validateJwt = async (jwt: string): Promise<boolean> => {
  const projectId = config.projectId;
  const jwtVerifyOptions = {
    algorithms: ["RS256"],
    audience: projectId,
    clockTolerance: 5,
    issuer: `https://securetoken.google.com/${projectId}`,
  };

  try {
    await jwtVerify(jwt, getKey, jwtVerifyOptions);
  } catch {
    return false;
  }

  return true;
};

const authMiddleware = async (ctx: Context, next: any) => {
  const headers: Headers = ctx.request.headers;
  // Taking JWT from Authorization header and comparing if it is valid JWT token, if YES - we continue,
  // otherwise we return with status code 401
  const authorization = headers.get("Authorization");
  if (!authorization) {
    ctx.response.status = 401;
    ctx.response.body = { message: "Missing authorization header" };
    return;
  }

  const jwt = authorization.split(" ")[1];
  if (!jwt) {
    ctx.response.status = 401;
    ctx.response.body = { message: "Malformed jwt token" };
    return;
  }

  if (await validateJwt(jwt)) {
    // eslint-disable-next-line callback-return
    await next();
  } else {
    ctx.response.status = 401;
    ctx.response.body = { message: "Invalid jwt token" };
  }
};

export default authMiddleware;
