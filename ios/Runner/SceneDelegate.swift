import UIKit
import Flutter

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // 使用FlutterViewController作为根视图控制器
        let flutterViewController = FlutterViewController(project: nil, nibName: nil, bundle: nil)
        let navigationController = UINavigationController(rootViewController: flutterViewController)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
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