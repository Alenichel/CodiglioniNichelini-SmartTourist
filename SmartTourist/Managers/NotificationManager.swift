//
//  NotificationManager.swift
//  SmartTourist
//
//  Created on 27/11/2019
//

import Foundation
import Hydra
import UserNotifications


class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        self.registerActions()
    }
        
    private let nc = UNUserNotificationCenter.current()
    private let identifier = "smart-tourist"
    
    var onPermissionGranted: (() -> Void)?
    var onPermissionDeclined: (() -> Void)?
        
    func requestAuth() {
        self.nc.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print(error.localizedDescription)
                self.onPermissionDeclined?()
            }
            if granted {
                print("Notification permission granted")
                self.onPermissionGranted?()
            }
        }
    }
    
    var notificationsEnabled: Bool {
        let promise = Promise<Bool>(in: .background) { resolve, reject, status in
            self.nc.getNotificationSettings(completionHandler: {settings in
                resolve(settings.authorizationStatus == .authorized)
            })
        }
        do {
            let value = try await(promise)
            return value
        } catch {
            return false
        }
    }
    
    func setDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        self.nc.delegate = delegate
    }
    
    func scheduleNotification(body: String) {
        let content = UNMutableNotificationContent()
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = self.identifier
        let category = UNNotificationCategory(identifier: self.identifier, actions: [], intentIdentifiers: [], options: [])
        self.nc.setNotificationCategories([category])
        let date = Date() + TimeInterval(1)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: self.identifier, content: content, trigger: trigger)
        self.nc.add(request)
    }
    
    func registerActions() {
        let seeMoreAction = UNNotificationAction(identifier: "VIEW_ACTION",
                                                 title: "View",
                                                 options: [])
        let takeMeThereAction = UNNotificationAction(identifier: "TAKE_ME_THERE_ACTION",
                                                     title: "Take me there",
                                                     options: [])
        let topAttractionCategory =
            UNNotificationCategory(identifier: "NEARBY_TOP_ATTRACTION",
                                   actions: [seeMoreAction, takeMeThereAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: .customDismissAction)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([topAttractionCategory])
    }
    
    func sendNearbyTopAttractionNotification(place: GPPlace) {
        let content = UNMutableNotificationContent()
        content.title = "Nearby Top Location"
        content.body = "You are near a top location: \(place.name)"
        content.sound = UNNotificationSound.default
        content.userInfo = ["PLACE_ID": place.placeID, "COORDINATES": "\(place.location.latitude),\(place.location.longitude)"]
        content.categoryIdentifier = "NEARBY_TOP_ATTRACTION"
        let date = Date() + TimeInterval(1)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: self.identifier, content: content, trigger: trigger)
        self.nc.add(request)
    }
}
