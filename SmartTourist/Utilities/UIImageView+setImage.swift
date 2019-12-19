//
//  UIImageView+setImage.swift
//  SmartTourist
//
//  Created on 05/12/2019
//

import Foundation
import UIKit


extension UIImageView {
    func setImage(_ photo: GPPhoto){
        GoogleAPI.shared.getPhoto(photo).then { image in
            self.image = image
        }
    }
}
