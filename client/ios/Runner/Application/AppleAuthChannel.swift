import AuthenticationServices
import CryptoKit

#if os(OSX)
import FlutterMacOS
#elseif os(iOS)
import Flutter
#endif

public class AppleAuthChannel {
    public static func register(with messanger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gutlogic.app/apple",
            binaryMessenger: messanger
        )
        
        if #available(iOS 13.0, *) {
            channel.setMethodCallHandler(AppleAuthAvailableDelegate().handle)
        } else {
            channel.setMethodCallHandler(AppleAuthUnavailableDelegate().handle)
        }
    }
}

/// AppleAuthUnavailableDelegate handles Flutter method calls on platforms where Apple authentication is unavailable.
private class AppleAuthUnavailableDelegate {
    public func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(call.method == "available" ? false : AppleAuthError.unavailable())
    }
}


/// AppleAuthAvailableDelegate handles Flutter method calls on platforms where Apple authentication is available.
@available(iOS 13.0, *)
private class AppleAuthAvailableDelegate {
    // We keep a reference to the last request so it doesn't deallocate.
    var _request: AppleAuthRequestController?
    
    public func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if _request?.resolved == false {
            result(AppleAuthError.concurrentRequest())
            return
        }
        
        switch (call.method) {
        case "available":
            result(true)
        case "authenticate":
            handleAuthenticate(call, result)
        case "getExistingAccount":
            handleGetExistingAccount(call, result)
        case "getCredentialState":
            handleGetCredentialState(call, result)
        case "deauthenticate":
            handleDeauthenticate(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Handle an "authenticate" method call.
    func handleAuthenticate(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(AppleAuthError.missingArgument())
            return
        }
        
        guard let nonce = args["nonce"] as? String else {
            result(AppleAuthError.missingArgument(key: "nonce"))
            return
        }
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce
        
        _request = AppleAuthRequestController([request], result)
    }
    
    /// Handle a "getExistingAccount" method call.
    func handleGetExistingAccount(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let request = ASAuthorizationPasswordProvider().createRequest()

        _request = AppleAuthRequestController([request], result)
    }
    
    /// Handle a "state" method call.
    func handleGetCredentialState(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(AppleAuthError.missingArgument())
            return
        }
        
        guard let userID = args["user_id"] as? String else {
            result(AppleAuthError.missingArgument(key: "user_id"))
            return
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        appleIDProvider.getCredentialState(forUserID: userID) { state, error in
            if let error = error {
                result(AppleAuthError.credentialStateError(error.localizedDescription))
                return
            }
            
            switch state {
            case .authorized:
                result("authorized")
            case .revoked:
                result("revoked")
            default:
                result("unknown")
            }
        }
    }
    
    /// Handle a "deauthentcate" method call.
    func handleDeauthenticate(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result(true) // TODO : is there anything special we need to do to deauthenticate?
    }
}

@available(iOS 13.0, *)
private class AppleAuthRequestController: NSObject, ASAuthorizationControllerDelegate {
    var callback: FlutterResult
    private(set) var resolved: Bool
    
    public init(_ requests: [ASAuthorizationRequest], _ callback: @escaping FlutterResult) {
        self.callback = callback
        self.resolved = false
        
        super.init()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            resolveAppleIDCredential(appleIDCredential)
        case let passwordCredential as ASPasswordCredential:
            resolvePasswordCredential(passwordCredential)
        default:
            callback(AppleAuthError.unknownCredentials())
        }
        
        resolved = true
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let message = error.localizedDescription;
        
        if let error = error as? ASAuthorizationError {
            callback(AppleAuthError.authorizationError(error.code, message))
        } else {
            callback(AppleAuthError.authorizationError(ASAuthorizationError.Code.unknown, message))
        }
        
        resolved = true
    }
    
    func resolveAppleIDCredential(_ appleIDCredential: ASAuthorizationAppleIDCredential) {
        guard let appleIDIdentityToken = appleIDCredential.identityToken else {
            callback(AppleAuthError.missingIDToken())
            return
        }
        
        guard let appleIDAuthorizationCode = appleIDCredential.authorizationCode else {
            callback(AppleAuthError.missingAccessToken())
            return
        }
        
        guard let deserializedIDToken = String(data: appleIDIdentityToken, encoding: .utf8) else {
            callback(AppleAuthError.malformedIDToken())
            return
        }
        
        guard let deserializedAccessToken = String(data: appleIDAuthorizationCode, encoding: .utf8) else {
            callback(AppleAuthError.malformedAccessToken())
            return
        }
        
        callback([
            "type": "appleid",
            "state": appleIDCredential.state,
            "email": appleIDCredential.email,
            "user_id": appleIDCredential.user,
            "short_name": appleIDCredential.fullName?.nickname,
            "given_name": appleIDCredential.fullName?.givenName,
            "family_name": appleIDCredential.fullName?.familyName,
            "id_token": deserializedIDToken,
            "access_token": deserializedAccessToken
        ])
    }
    
    func resolvePasswordCredential(_ passwordCredential: ASPasswordCredential) {
        callback([
            "type": "password",
            "used_id": passwordCredential.user,
            "password": passwordCredential.password,
        ])
    }
}

private class AppleAuthError {
    private init() {}
    
    static func unavailable() -> FlutterError {
        return FlutterError(code: "PLATFORM_UNAVAILABLE", message: "Apple Authentication is not available on this platform.", details: nil)
    }
    
    static func concurrentRequest() -> FlutterError {
        return FlutterError(code: "CONCURRENT_REQUEST", message: "Another request is still pending.", details: nil)
    }
    
    @available(iOS 13.0, *)
    static func missingArgument() -> FlutterError {
        return FlutterError(code: "MISSING_ARGUMENT", message: "Missing arguments from call.", details: nil)
    }
    
    @available(iOS 13.0, *)
    static func missingArgument(key: String) -> FlutterError {
        return FlutterError(code: "MISSING_ARGUMENT", message: "Missing argument '\(key)' from call.", details: nil)
    }
    
    @available(iOS 13.0, *)
    static func missingIDToken() -> FlutterError {
        return FlutterError(code: "MISSING_ID_TOKEN", message: "Credentials are missing an identity token.", details: nil)
    }
    
    @available(iOS 13.0, *)
    static func missingAccessToken() -> FlutterError {
        return FlutterError(code: "MISSING_ACCESS_TOKEN", message: "Credentials are missing an access token.", details: nil)
    }
    
    @available(iOS 13.0, *)
    static func malformedIDToken() -> FlutterError {
        return FlutterError(code: "MALFORMED_ID_TOKEN", message: "Unable to deserialize identity token.", details: nil)
    }
    
    @available(iOS 13.0, *)
    static func malformedAccessToken() -> FlutterError {
        return FlutterError(code: "MALFORMED_ACCESS_TOKEN", message: "Unable to deserialize access token.", details: nil)
    }
    
    @available(iOS 13.0, *)
    static func credentialStateError(_ message: String) -> FlutterError {
        return FlutterError(code: "CREDENTIAL_STATE_ERROR", message: message, details: nil)
    }
    
    @available(iOS 13.0, *)
    static func authorizationError(_ code: ASAuthorizationError.Code, _ message: String) -> FlutterError {
        var flutterErrorCode = "AUTHORIZATION_ERROR/UNKNOWN"
        
        switch (code) {
        case .canceled:
            flutterErrorCode = "AUTHORIZATION_ERROR/CANCELED"
        case .invalidResponse:
            flutterErrorCode = "AUTHORIZATION_ERROR/INVALID_RESPONSE"
        case .notHandled:
            flutterErrorCode = "AUTHORIZATION_ERROR/NOT_HANDLED"
        case .failed:
            flutterErrorCode = "AUTHORIZATION_ERROR/FAILED"
        case .unknown:
            flutterErrorCode = "AUTHORIZATION_ERROR/UNKNOWN"
        @unknown default:
            flutterErrorCode = "AUTHORIZATION_ERROR/UNKNOWN"
        }
        
        return FlutterError(code: flutterErrorCode, message: message, details: nil)
    }
    
    @available(iOS 13.0, *)
    static func unknownCredentials() -> FlutterError {
        return FlutterError(code: "UNKNOWN_CREDENTIALS", message: "Unknown credentials.", details: nil)
    }
}
