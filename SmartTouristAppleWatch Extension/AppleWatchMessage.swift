//
//  AppleWatchMessage.swift
//  SmartTourist
//
//  Created on 27/03/2020
//

import Foundation


enum AppleWatchMessage: String {
    case getPlaces
    case getDetail
    case test
    
    enum PlaceType: String {
        case nearest
        case popular
        case favorites
    }
}
