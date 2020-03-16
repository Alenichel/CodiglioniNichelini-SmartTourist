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
    let pedometer: CMPedometer
    
    private init(){
        self.pedometer = CMPedometer()
    }
    
    func startUpdates(_ handler: @escaping CMPedometerHandler) {
        guard CMPedometer.isPaceAvailable() else { return }
        self.pedometer.stopUpdates()
        self.pedometer.startUpdates(from: Date(), withHandler: handler)
        /*self.pedometer.startUpdates(from: Date(), withHandler: { data, error in
            if let data = data {
                updateWalkingGlobalVar(data.averageActivePace as! Double)
                print("New average walking speed is \(averageWalkingSpeed)")
                print("New littleCircleRadius is \(littleCircleRadius)")
                print("New bigCircleRadius is \(littleCircleRadius)")
            }
        })*/
    }
}
