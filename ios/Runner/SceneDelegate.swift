import UIKit
import Flutter

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // 使用Flutter的默认配置
        if let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate {
            appDelegate.window = window
        }
        
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 当场景断开连接时调用
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 当场景变为活动状态时调用
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 当场景将变为非活动状态时调用
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 当场景将进入前台时调用
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 当场景进入后台时调用
    }
}