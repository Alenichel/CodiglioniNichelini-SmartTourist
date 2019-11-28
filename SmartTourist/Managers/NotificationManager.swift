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
    private init() {}
        
    private let nc = UNUserNotificationCenter.current()
    private let identifier = "smart-tourist"
        
    func requestAuth() {
        self.nc.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if granted {
                print("Notification permission granted")
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
        
}
