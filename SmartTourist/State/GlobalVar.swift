//
//  GlobalVar.swift
//  SmartTourist
//
//  Created on 10/03/2020
//

import Foundation

var averageWalkingSpeed: Double = defaultAverageWalkingSpeed
var littleCircleRadius: Double = averageWalkingSpeed*littleCircleTimeRadius // meters
var bigCircleRadius: Double = averageWalkingSpeed*bigCircleTimeRadius//meters

func updateWalkingGlobalVar(_ newSpeed: Double) {
    averageWalkingSpeed = newSpeed
    littleCircleRadius = averageWalkingSpeed*littleCircleTimeRadius
    bigCircleRadius = averageWalkingSpeed*bigCircleTimeRadius
}
