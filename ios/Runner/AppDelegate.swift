import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  let channel = "apns_token"
  var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
  
    let controller = window?.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: channel, binaryMessenger: controller.binaryMessenger)

    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "register" {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          DispatchQueue.main.async {
            if granted {
              application.registerForRemoteNotifications()
            }
          }
        }
        result(nil)
      }
    }
  
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Receive APNs device token
  override func application(_ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    methodChannel?.invokeMethod("onApnsToken", arguments: token)
  }

  // Handle failure
  override func application(_ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNs registration failed: \(error)")
  }
}
