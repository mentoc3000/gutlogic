import { X509Certificate } from "crypto";
import * as jose from "jose";
import { APPLE_ROOT_CA_G3_FINGERPRINT } from "./AppleRootCertificate";
import { CertificateValidationError } from "./Errors";
import {
  DecodedNotificationPayload,
  JWSRenewalInfo,
  JWSRenewalInfoDecodedPayload,
  JWSTransaction,
  JWSTransactionDecodedPayload,
} from "./Models";

export async function decodeTransactions(
  signedTransactions: JWSTransaction[],
): Promise<JWSTransactionDecodedPayload[]> {
  return Promise.all(signedTransactions.map(decodeJWS));
}

export async function decodeTransaction(transaction: JWSTransaction): Promise<JWSTransactionDecodedPayload> {
  return decodeJWS(transaction);
}

export async function decodeRenewalInfo(info: JWSRenewalInfo): Promise<JWSRenewalInfoDecodedPayload> {
  return decodeJWS(info);
}

export async function decodeNotificationPayload(payload: string): Promise<DecodedNotificationPayload> {
  return decodeJWS(payload);
}

/**
 * Decodes and verifies an object signed by the App Store according to JWS.
 * See: https://developer.apple.com/documentation/appstoreserverapi/jwstransaction
 */
async function decodeJWS(token: string): Promise<any> {
  // Extracts the key used to sign the JWS from the header of the token
  const getKey: jose.CompactVerifyGetKey = async (protectedHeader, _token) => {
    // RC 7515 stipulates that the key used to sign the JWS must be the first in the chain.
    // https://datatracker.ietf.org/doc/html/rfc7515#section-4.1.6

    // jose will not import the certificate unless it is in a proper PKCS8 format.
    const certs = protectedHeader.x5c?.map((c) => `-----BEGIN CERTIFICATE-----\n${c}\n-----END CERTIFICATE-----`) ?? [];

    validateCertificates(certs);

    return jose.importX509(certs[0], "ES256");
  };

  const { payload } = await jose.compactVerify(token, getKey);

  const decoded = new TextDecoder().decode(payload);
  const json = JSON.parse(decoded);

  return json;
}

/**
 * Validates a certificate chain provided in the x5c field of a decoded header of a JWS.
 * The certificates must be valid and have come from Apple.
 * @throws {CertificateValidationError} if any of the validation checks fail
 */
function validateCertificates(certificates: string[]) {
  if (certificates.length === 0) throw new CertificateValidationError([]);

  const x509certs = certificates.map((c) => new X509Certificate(c));

  // Check dates
  const now = new Date();
  const datesValid = x509certs.every((c) => new Date(c.validFrom) < now && now < new Date(c.validTo));
  if (!datesValid) throw new CertificateValidationError(certificates);

  // Check that each certificate, except for the last, is issued by the subsequent one.
  if (certificates.length >= 2) {
    for (let i = 0; i < x509certs.length - 1; i++) {
      const subject = x509certs[i];
      const issuer = x509certs[i + 1];

      if (subject.checkIssued(issuer) === false || subject.verify(issuer.publicKey) === false) {
        throw new CertificateValidationError(certificates);
      }
    }
  }

  // Ensure that the last certificate in the chain is the expected Apple root CA.
  if (x509certs[x509certs.length - 1].fingerprint256 !== APPLE_ROOT_CA_G3_FINGERPRINT) {
    throw new CertificateValidationError(certificates);
  }
}
