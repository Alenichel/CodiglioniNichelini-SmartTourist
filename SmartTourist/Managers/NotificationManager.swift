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
    
    static let notificationTriggeringDistance = 250    // meters
    
    private init() {
        self.registerActions()
    }
        
    private let nc = UNUserNotificationCenter.current()
    
    var onPermissionGranted: (() -> Void)?
    var onPermissionDeclined: (() -> Void)?
        
    func requestAuth() {
        self.nc.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("\(#function): \(error.localizedDescription)")
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
    
    func sendNearbyTopAttractionNotification(place: WDPlace) {
        Promise<UNNotificationRequest>(in: .background) { resolve, reject, status in
            let content = UNMutableNotificationContent()
            content.title = "Nearby Top Location"
            content.body = "You are near a top location: \(place.name)"
            content.sound = UNNotificationSound.default
            content.userInfo = ["PLACE_ID": place.placeID]
            let photos = place.photos
            if let photo = photos.first {
                let image = try await(WikipediaAPI.shared.getPhoto(imageURL: photo))
                if let attachment = UNNotificationAttachment.create(identifier: "PHOTO", image: image, options: nil) {
                    content.attachments.append(attachment)
                }
            }
            content.categoryIdentifier = "NEARBY_TOP_ATTRACTION"
            let date = Date() + TimeInterval(1)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            resolve(UNNotificationRequest(identifier: place.placeID, content: content, trigger: trigger))
        }.then(in: .utility) { request in
            self.nc.add(request)
        }
    }
}
