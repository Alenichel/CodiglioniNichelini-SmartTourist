//
//  SideEffects.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni on 24/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import Foundation
import Katana


struct GetCurrentPlace: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        DispatchQueue.main.async {
            context.dependencies.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                if let error = error {
                    print("Current Place error: \(error.localizedDescription)")
                    return
                }
                if let placeLikelihoodList = placeLikelihoodList {
                    if let place = placeLikelihoodList.likelihoods.first?.place, let placeName = place.name {
                        print("Current place: \(placeName)")
                        context.dispatch(SetCurrentPlace(place: placeName))
                    }
                }
            })
        }
    }
}
