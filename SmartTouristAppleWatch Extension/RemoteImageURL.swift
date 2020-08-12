//
//  RemoteImageURL.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 12/08/2020
//

import SwiftUI
import Combine
import Hydra


class RemoteImageURL: ObservableObject {
    @Published var image = UIImage()
    
    init(imageURL: URL) {
        WikipediaAPI.shared.getPhoto(imageURL: imageURL).then(in: .main) { image in
            self.image = image
        }.catch { error in
            print(imageURL)
            print(error.localizedDescription)
        }
    }
}
