//
//  Constants.swift
//  SmartTourist
//
//  Created on 14/02/2020
//

import Foundation


let apiThrottleTime: Double = 30   // seconds
let notificationTriggeringDistance = 250    // meters
let littleCircleRadius: Double = 200    // meters
let bigCircleRadius: Double = 800   //meters


enum SelectedPlaceList: Int {
    case nearest = 0
    case popular = 1
    case favorites = 2
}
