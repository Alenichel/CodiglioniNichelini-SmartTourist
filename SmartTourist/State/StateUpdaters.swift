//
//  StateUpdaters.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni on 24/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import Foundation
import Katana


struct SetCurrentPlace: StateUpdater {
    let place: String
    
    func updateState(_ state: inout AppState) {
        state.currentPlace = place
    }
}
