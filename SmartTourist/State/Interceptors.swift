//
//  Interceptors.swift
//  SmartTourist
//
//  Created on 05/12/2019
//

import Foundation
import Katana
import Hydra


protocol Persistable: Dispatchable {}


struct PersistorInterceptor {
    static func interceptor() -> StoreInterceptor {
        return { context in
            return { next in
                return { dispatchable in
                    try next(dispatchable)
                    guard let _ = dispatchable as? Persistable else { return }
                    guard let state = context.getAnyState() as? AppState else { return }
                    async(in: .utility) {
                        let encoder = JSONEncoder()
                        do {
                            let data = try encoder.encode(state)
                            try data.write(to: AppState.persistURL)
                            print("State persisted to \(AppState.persistURL)")
                        } catch {
                            print("\(#function): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
