//
//  AppDelegate.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import UIKit
import UserNotifications
import GoogleMaps
import GooglePlaces
import Katana
import Tempura
import WatchConnectivity

/// UNUserNotificationCenterDelegate let you send notifications and handle their callback actions
/// It contains two optional methods:
/// - userNotificationCenter(_:willPresent:withCompletionHandler:) called when the application is in the foreground
/// - userNotificationCenter (_: didReceive:withCompletionHandler:) is used to select an action for a notification

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var store: Store<AppState, DependenciesContainer>!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GoogleAPI.apiKey)
        GMSPlacesClient.provideAPIKey(GoogleAPI.apiKey)
        NotificationManager.shared.setDelegate(self)
        self.store = Store<AppState, DependenciesContainer>(interceptors: [
            //DispatchableLogger.interceptor(),
            PersistorInterceptor.interceptor()
        ])
        self.store.dispatch(LoadState())
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    /// This method will be called when app received push notifications in foreground
    /// Useful to show notifications even when the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    /// This method handles notification actions when they happens in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let window = UIApplication.shared.windows.first else { completionHandler(); return }
        guard let rootViewController = window.rootViewController as? UINavigationController else { completionHandler(); return }
        guard let attractionsViewController = rootViewController.viewControllers.first as? AttractionsViewController else { completionHandler(); return }
        guard let placeID = userInfo["PLACE_ID"] as? String else { completionHandler(); return }
        let store = attractionsViewController.store
        guard let place = store.state.locationState.popularPlaces.first(where: {$0.placeID == placeID}) else { completionHandler(); return }
        switch response.actionIdentifier {
        case "VIEW_ACTION":
            self.showDetailView(store: store, place: place)
        case "TAKE_ME_THERE_ACTION":
            guard let origin = store.state.locationState.actualLocation else { completionHandler(); return }
            let url = GoogleAPI.shared.buildDirectionURL(origin: origin, destination: place.location, destinationPlaceId: placeID)
            UIApplication.shared.open(url)
        case "com.apple.UNNotificationDefaultActionIdentifier":
            self.showDetailView(store: store, place: place)
        case "com.apple.UNNotificationDismissActionIdentifier to dismiss":
            break
        default:
            break
        }
        completionHandler()
    }
    
    private func showDetailView(store: PartialStore<AppState>, place: GPPlace) {
        store.dispatch(Hide(Screen.cityDetail.rawValue, animated: true, atomic: true)).then {
            store.dispatch(Hide(Screen.citySearch.rawValue, animated: true, atomic: true)).then {   // This doesn't actually work
                store.dispatch(Hide(Screen.detail.rawValue, animated: true, atomic: true)).then {
                    store.dispatch(Show(Screen.detail, animated: true, context: place))
                }
            }
        }
    }
    
    // App becomes active
    // This method is called on first launch when app was closed / killed and every time app is reopened or change status from background to foreground (ex. mobile call)
    func applicationDidBecomeActive(_ application: UIApplication) {
        justVisitedPlaces.removeFirst(justVisitedPlaces.count - 1)
    }
}
