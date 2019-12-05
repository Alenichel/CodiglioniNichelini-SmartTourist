//
//  DetailImage.swift
//  SmartTourist
//
//  Created on 05/12/2019
//

import Foundation
import UIKit
import GooglePlaces

class DetailImage {
    var img: UIImage?
    var imgMetadata: GMSPlacePhotoMetadata
    
    init(place: GMSPlace) {
        self.imgMetadata = (place.photos?.first)!
        self.fetch()
    }
    
    func fetch(){
        GoogleAPI.shared.getPlacePicture(photoMetadata: self.imgMetadata).then{ image in
            self.img = image
        }
    }
}

extension UIImageView {
    
    func setImage(img: DetailImage){
        img.fetch()
        self.image = img.img
    }
}
