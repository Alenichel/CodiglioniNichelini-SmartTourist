//
//  PedometerHandler.swift
//  SmartTourist
//
//  Created on 10/03/2020
//

import Foundation
import CoreMotion

class PedometerHandler {
    static let shared = PedometerHandler()
    
    static let defaultAverageWalkingSpeed: Double = 1.34    // m/s
    static let littleCircleTimeRadius: Double = 5*60        // seconds
    static let bigCircleTimeRadius: Double = 15*60          // seconds
    
    let pedometer: CMPedometer
    
    private init(){
        self.pedometer = CMPedometer()
    }
    
    func startUpdates(_ handler: @escaping CMPedometerHandler) {
        guard CMPedometer.isPaceAvailable() else { return }
        self.pedometer.stopUpdates()
        self.pedometer.startUpdates(from: Date(), withHandler: handler)
    }
}
