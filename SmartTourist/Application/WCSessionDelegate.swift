//
//  WCSessionDelegate.swift
//  SmartTourist
//
//  Created on 26/03/2020
//

import Foundation
import WatchConnectivity


extension SceneDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let typeString = message["type"] as? String, let type = AppleWatchMessage(rawValue: typeString) else { return }
        switch type {
        case .test:
            print("MESSAGE RECEIVED")
            replyHandler(message)
        default:
            print("ELSE")
        }
    }
}


enum AppleWatchMessage: String {
    case getNearestPlaces
    case getPopularPlaces
    case getFavoritePlaces
    case getDetail
    case test
}
