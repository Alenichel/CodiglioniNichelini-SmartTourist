//
//  UNNotificationAttachment+UIImage.swift
//  SmartTourist
//
//  Created on 24/03/2020
//

import UIKit
import UserNotifications


extension UNNotificationAttachment {
    /// Save the image to disk
    static func create(identifier: String, image: UIImage, fileExtension: String, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier + "." + fileExtension
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            var imageDataTmp: Data?
            if fileExtension == "jpg" || fileExtension == "jpeg" {
                imageDataTmp = image.jpegData(compressionQuality: 1)
            } else if fileExtension == "png" {
                imageDataTmp = image.pngData()
            } else {
                fatalError("Unrecognized image format")
            }
            guard let imageData = imageDataTmp else { return nil }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("\(#function): \(error.localizedDescription)")
        }
        return nil
    }
}
