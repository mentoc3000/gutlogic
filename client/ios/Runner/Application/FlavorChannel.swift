import Foundation

public class FlavorChannel {
    public static func register(with messanger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gutlogic.app/flavor",
            binaryMessenger: messanger
        )
        channel.setMethodCallHandler(FlavorChannel().handle)
    }
    
    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "get") {
            result(Bundle.main.infoDictionary?["Flavor"])
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
