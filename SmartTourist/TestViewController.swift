//
//  ViewController.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni on 23/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import PinLayout

class TestViewController: UIViewController, CLLocationManagerDelegate {

    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()

    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    var nameLabel: UILabel = UILabel()
    var addressLabel: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        let locationManager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                locationManager.distanceFilter = 250
        } else {
            let alert = UIAlertController(title: "Attention!", message: "Location services not enabled", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        getCurrentPlace()
    }

    // Add a UIButton in Interface Builder, and connect the action to this function.
    func getCurrentPlace() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Current Place error: \(error.localizedDescription)")
                return
            }

            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""

            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    print(place.name ?? "Hello, world")
                    self.nameLabel.text = place.name
                    self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        })
    }
}
