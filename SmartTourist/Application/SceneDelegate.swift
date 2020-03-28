//
//  SceneDelegate.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import UIKit
import Katana
import Tempura
import WatchConnectivity


class SceneDelegate: UIResponder, UIWindowSceneDelegate, RootInstaller {

    var window: UIWindow?
    var store: Store<AppState, DependenciesContainer>? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil}
        return appDelegate.store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard
            let windowScene = (scene as? UIWindowScene),
            let store = self.store
        else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigator: Navigator! = store.dependencies.navigator
        navigator.start(using: self, in: self.window!, at: Screen.attractions)
        window?.windowScene = windowScene
    }
    
    func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: () -> ()) -> Bool {
        guard let store = self.store else { return false }
        if identifier == Screen.attractions.rawValue {
            let viewController = AttractionsViewController(store: store, localState: AttractionsLocalState())
            let navigationController = UINavigationController(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            completion()
            return true
        }
        return false
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

