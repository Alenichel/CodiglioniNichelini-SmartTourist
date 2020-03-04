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
import Tempura

/// UNUserNotificationCenterDelegate let you send notifications and handle their callback actions
/// It contains two optional methods:
/// - userNotificationCenter(_:willPresent:withCompletionHandler:) called when the application is in the foreground
/// - userNotificationCenter (_: didReceive:withCompletionHandler:) is used to select an action for a notification

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GoogleAPI.apiKey)
        GMSPlacesClient.provideAPIKey(GoogleAPI.apiKey)
        NotificationManager.shared.setDelegate(self)
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
        switch response.actionIdentifier {
        case "VIEW_ACTION":
            print("----> VIEW ACTION")
        default:
            print("----> DEFAULT")
            let window = UIApplication.shared.windows.first
            let rc = window?.rootViewController as! UINavigationController
            let store = (rc.topViewController as! ViewControllerWithLocalState<MapView>).store
            let placeName = userInfo["ATTRACTION_NAME"] as! String
            var place : GPPlace?
            for p in store.state.locationState.popularPlaces {
                if p.name == placeName { place = p }
            }
            let lc = AttractionDetailLocalState(attraction: place!)
            let wc = AttractionDetailViewController(store: store, localState: lc)
            (rc ).pushViewController(wc, animated: true)
        }

        completionHandler()
    }
    
    // App becomes active
    // This method is called on first launch when app was closed / killed and every time app is reopened or change status from background to foreground (ex. mobile call)
    func applicationDidBecomeActive(_ application: UIApplication) {
        justVisitedPlaces.removeFirst(justVisitedPlaces.count - 1)
    }
}


