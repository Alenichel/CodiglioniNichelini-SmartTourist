//
//  Blacklist.swift
//  SmartTourist
//
//  Created on 16/03/2020
//

import Foundation

func blacklist(_ placesList: [GPPlace]) -> [GPPlace] {
    var filtered = placesList.filter({ place in
        if let rating = place.rating {
            return rating > 0.0
        } else {return false}
    })
    filtered = filtered.filter({ place in
        return !place.name.containsEmoji
    })
    return filtered
}
