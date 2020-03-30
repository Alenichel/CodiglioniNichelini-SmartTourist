//
//  PlaceRowView.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 27/03/2020
//

import SwiftUI


struct PlaceRowView: View {
    @EnvironmentObject private var userData: UserData
    var place: AWGPPlace
    
    var placeIndex: Int {
        userData.places.firstIndex(where: { $0.id == place.id })!
    }
    
    var body: some View {
        HStack {
            if place.image != nil {
                CircleImage(image: place.image!)
                    .frame(width: 50, height: 50)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            }
            /*place.image?
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))*/
            Text(place.name)
        }
    }
}


struct PlaceRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlaceRowView(place: userData.places[0])
            PlaceRowView(place: userData.places[1])
        }.previewLayout(.fixed(width: 300, height: 70))
    }
}
