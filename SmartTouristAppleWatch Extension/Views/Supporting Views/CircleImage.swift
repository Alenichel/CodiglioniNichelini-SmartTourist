//
//  CircleImage.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 28/03/2020
//

import SwiftUI

struct CircleImage: View {
    @ObservedObject var imageURL: RemoteImageURL
    
    init(imageURL: URL) {
        self.imageURL = RemoteImageURL(imageURL: imageURL)
    }

    var body: some View {
        Image(uiImage: imageURL.image)
            .resizable()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(radius: 10)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(imageURL: Bundle.main.url(forResource: "empire", withExtension: "png") ?? URL(string: "")!)
            .frame(width: 120, height: 120)
            .padding()
    }
}
