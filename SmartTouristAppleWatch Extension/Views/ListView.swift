//
//  ListView.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 26/03/2020
//

import SwiftUI
import CoreLocation


struct ListView: View {
    @EnvironmentObject private var userData: UserData
        
    var body: some View {
        Group {
            if self.userData.places.isEmpty {
                LoadingView().frame(width: 50, height: 50)
            } else {
                List {
                    ForEach(userData.places) { place in
                        NavigationLink(destination: PlaceDetailView(place: place).environmentObject(self.userData)) {
                            PlaceRowView(place: place).environmentObject(self.userData)
                        }
                    }
                }
            }
        }
        .contextMenu(menuItems: {
            Group {
                Button(action: {
                    DispatchQueue.main.async {
                        self.userData.places = []
                    }
                    self.userData.placesType = .nearest
                    self.userData.getPlaces(type: .nearest)
                }) {
                    VStack {
                        Image(systemName: "map.fill")
                        Text("Nearest")
                    }
                }
                Button(action: {
                    DispatchQueue.main.async {
                        self.userData.places = []
                    }
                    self.userData.placesType = .popular
                    self.userData.getPlaces(type: .popular)
                }) {
                    VStack {
                        Image(systemName: "star.fill")
                        Text("Popular")
                    }
                }
            }
        })
        .navigationBarTitle(Text("SmartTourist"))
    }
}


struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .environmentObject(userData)
    }
}
