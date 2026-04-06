import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.setupMethodChannel(binaryMessenger: controller.binaryMessenger)
  }
}
