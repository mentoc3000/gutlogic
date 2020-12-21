import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Grab a reference to the application messanger.
    let controller = window.rootViewController as! FlutterViewController
    let messanger = controller.binaryMessenger;
    
    // Register our custom application channels.
    AppleAuthChannel.register(with: messanger)
    FlavorChannel.register(with: messanger)
    
    // Register other native plugins from our dependencies.
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
