import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  var methodChannel: FlutterMethodChannel?

  func setupMethodChannel(binaryMessenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "register" {
        self?.requestPushPermissions(application: UIApplication.shared)
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func requestPushPermissions(application: UIApplication) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
        if granted {
            DispatchQueue.main.async {
                // 2. This triggers didRegisterForRemoteNotificationsWithDeviceToken
                application.registerForRemoteNotifications()
            }
        }
    }
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      // 3. Convert token to hex string
      let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
      
      // 4. Send to Flutter
      methodChannel?.invokeMethod("onApnsToken", arguments: token)
      
      // Also call super to ensure Flutter plugins get the token too
      super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      methodChannel?.invokeMethod("onTokenError", arguments: error.localizedDescription)
      super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
