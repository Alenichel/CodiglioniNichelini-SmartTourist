//
//  Model.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni & Alessandro Nichelini on 23/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import Foundation

struct Location: Equatable {
    var lon: Double
    var lat: Double
}

struct Place: Equatable {
    var name: String
    var location: Location
}
