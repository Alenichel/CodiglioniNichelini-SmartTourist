//
//  GMSMapView + loadCustomStyle().swift
//  SmartTourist
//
//  Created on 22/12/2019
//

import Foundation
import GoogleMaps

extension GMSMapView {
    func loadCustomStyle() {
        do {
            let style = UITraitCollection.current.userInterfaceStyle == .dark ? "mapStyle.dark" : "mapStyle"
            if let styleURL = Bundle.main.url(forResource: style, withExtension: "json") {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
    }
}
