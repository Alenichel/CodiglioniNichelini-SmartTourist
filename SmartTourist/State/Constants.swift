//
//  Constants.swift
//  SmartTourist
//
//  Created on 14/02/2020
//

import Foundation


let apiThrottleTime: Double = 30   // seconds
let notificationTriggeringDistance = 250    // meters
let averageWalkingSpeed: Double = 1.34 //meters/second
let littleCircleTimeRadius: Double = 5*60 //seconds
let bigCircleTimeRadius: Double = 15*60 //seconds
let littleCircleRadius: Double = averageWalkingSpeed*littleCircleTimeRadius // meters
let bigCircleRadius: Double = averageWalkingSpeed*bigCircleTimeRadius//meters

enum SelectedPlaceList: Int {
    case nearest = 0
    case popular = 1
    case favorites = 2
}
