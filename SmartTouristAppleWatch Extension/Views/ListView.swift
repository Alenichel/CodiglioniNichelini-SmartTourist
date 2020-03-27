//
//  ListView.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 26/03/2020
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject private var userData: UserData
        
    var body: some View {
        List {
            ForEach(userData.places) { place in
                PlaceRowView(place: place).environmentObject(self.userData)
            }
        }
        .contextMenu(menuItems: {
            Group {
                Button(action: {
                    self.userData.getPlaces(type: .nearest)
                }) {
                    VStack {
                        Image(systemName: "map.fill")
                        Text("Nearest")
                    }
                }
                Button(action: {
                    self.userData.getPlaces(type: .popular)
                }) {
                    VStack {
                        Image(systemName: "star.fill")
                        Text("Popular")
                    }
                }
                Button(action: {
                    self.userData.getPlaces(type: .favorites)
                }) {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("Favorites")
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
