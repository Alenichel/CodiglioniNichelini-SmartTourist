//
//  String+UIImage.swift
//  SmartTourist
//
//  Created on 14/04/2020
//

import UIKit


extension String {
    var image: UIImage {
        let data = self.data(using: .utf8, allowLossyConversion: true)
        let drawText = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        let label = UILabel()
        label.text = self
        label.sizeToFit()
        let size = label.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawText?.draw(in: CGRect(x: 10, y: 0, width: size.width, height: size.height), withAttributes: nil)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
