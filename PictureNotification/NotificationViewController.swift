//
//  NotificationViewController.swift
//  PictureNotification
//
//  Created on 24/03/2020
//

import UIKit
import UserNotifications
import UserNotificationsUI
import PinLayout

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    let imageView = UIImageView()
    
    override func loadView() {
        super.loadView()
        self.view = UIView()
        view.addSubview(self.imageView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.pin.size(UIScreen.main.bounds.size.width)
        self.imageView.pin.all()
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let attachment = notification.request.content.attachments.first else { return }
        do {
            let data = try Data(contentsOf: attachment.url)
            let image = UIImage(data: data)
            self.imageView.image = image
        } catch {
            print(error.localizedDescription)
        }
    }
}
