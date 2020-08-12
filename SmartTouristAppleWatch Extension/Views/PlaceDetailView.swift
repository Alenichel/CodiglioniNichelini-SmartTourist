//
//  PlaceDetailView.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 28/03/2020
//

import SwiftUI


struct PlaceDetailView: View {
    @EnvironmentObject private var userData: UserData
    var place: AWPlace
    
    var index: Int {
        self.userData.placeDetails.firstIndex(where: { $0.id == place.id}) ?? -1
    }
    
    var body: some View {
        Group {
            if index >= 0 {
                ScrollView {
                    CircleImage(imageURL: self.userData.placeDetails[index].awPlace.photoURL)
                        .frame(width: 120, height: 120)
                        .padding()
                    Text(self.userData.placeDetails[index].description)
                    .lineLimit(nil)
                }
                .navigationBarTitle(Text(self.userData.placeDetails[index].awPlace.name))
            } else {
                LoadingView().frame(width: 50, height: 50)
            }
        }.onAppear {
            self.userData.getPlaceDetail(self.place)
        }
    }
}


struct PlaceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetailView(place: userData.places[0]).environmentObject(userData)
    }
}
