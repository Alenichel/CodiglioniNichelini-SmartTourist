//
//  NotificationManager.swift
//  SmartTourist
//
//  Created on 27/11/2019
//

import Foundation
import UserNotifications


class NotificationManager {
    static let shared = NotificationManager()
        
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
        var date = Date()
        print(date)
        date += TimeInterval(5)
        print(date)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: self.identifier, content: content, trigger: trigger)
        self.nc.add(request)
    }
        
}
