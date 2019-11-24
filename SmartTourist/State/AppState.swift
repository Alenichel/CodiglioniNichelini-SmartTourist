//
//  AppState.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni & Alessandro Nichelini on 23/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import Foundation
import Katana

// MARK: - State
struct AppState: State {
    var firstLaunch: Bool = true
    var currentPlace: String?
    var loading: Bool = false
}
