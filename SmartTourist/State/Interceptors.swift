//
//  Interceptors.swift
//  SmartTourist
//
//  Created on 05/12/2019
//

import Foundation
import Katana


struct PersistorInterceptor {
    static func interceptor() -> StoreInterceptor {
        return { context in
            return { next in
                return { dispatchable in
                    try next(dispatchable)
                    DispatchQueue.global(qos: .utility).async {
                        guard let _ = dispatchable as? Persistable else { return }
                        guard let state = context.getAnyState() as? AppState else { return }
                        let encoder = JSONEncoder()
                        print(AppState.persistURL)
                        do {
                            let data = try encoder.encode(state)
                            try data.write(to: AppState.persistURL)
                            print("State persisted to \(AppState.persistURL)")
                        } catch {
                            print("Error while encoding JSON")
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
