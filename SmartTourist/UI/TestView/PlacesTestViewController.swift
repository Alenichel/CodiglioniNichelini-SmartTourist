//
//  PlacesTestViewController.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import CoreLocation
import Tempura
import GooglePlaces


class PlacesTestViewController: ViewController<PlacesTestView>, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func setupInteraction() {
        self.rootView.didTapButton = { [unowned self] in
            self.dispatch(GetCurrentPlace())
        }
    }
}
