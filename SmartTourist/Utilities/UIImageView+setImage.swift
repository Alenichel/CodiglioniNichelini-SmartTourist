//
//  UIImageView+setImage.swift
//  SmartTourist
//
//  Created on 05/12/2019
//

import Foundation
import UIKit
import GooglePlaces

extension UIImageView {
    func setImage(metadata: GMSPlacePhotoMetadata){
        GoogleAPI.shared.getPlacePicture(photoMetadata: metadata).then { image in
            self.image = image
        }
    }
}
