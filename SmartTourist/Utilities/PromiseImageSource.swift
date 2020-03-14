//
//  PromiseImageSource.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import ImageSlideshow
import Hydra


class PromiseImageSource: InputSource {
    let promise: Promise<UIImage>
    var image: UIImage?
    
    init(_ promise: Promise<UIImage>) {
        self.promise = promise
    }
    
    func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        if let image = self.image {
            imageView.image = image
            callback(image)
        } else {
            promise.then { image in
                self.image = image
            }.catch { error in
                print(error.localizedDescription)
                self.image = nil
            }.always {
                DispatchQueue.main.async {
                    imageView.image = self.image
                    callback(self.image)
                }
            }
        }
    }
}
