//
//  CircleImage.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 28/03/2020
//

import SwiftUI

struct CircleImage: View {
    var image: Image

    var body: some View {
        image
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(radius: 10)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image: Image("empire").resizable())
            .frame(width: 120, height: 120)
            .padding()
    }
}
