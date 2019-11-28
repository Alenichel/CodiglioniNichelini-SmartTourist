//
//  DependenciesContainer.swift
//  SmartTourist
//
//  Created 23/11/2019.
//

import Foundation
import Katana
import Tempura
import GooglePlaces


final class DependenciesContainer: NavigationProvider {
    let promisableDispatch: PromisableStoreDispatch
    let getAppState: () -> AppState
    let navigator = Navigator()
    let googleAPI = GoogleAPI()
    
    var getState: () -> State {
        return self.getAppState
    }

    init(dispatch: @escaping PromisableStoreDispatch, getAppState: @escaping () -> AppState) {
        self.promisableDispatch = dispatch
        self.getAppState = getAppState
    }
    
    convenience init(dispatch: @escaping PromisableStoreDispatch, getState: @escaping GetState) {
        let getAppState: () -> AppState = {
            guard let state = getState() as? AppState else {
                fatalError("Wrong State Type")
            }
            return state
        }
        self.init(dispatch: dispatch, getAppState: getAppState)
    }
}
