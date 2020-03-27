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
            place.image?
                .resizable()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(place.name)
                Text(place.city)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if place.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
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
