//
//  ContentView.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 26/03/2020
//

import SwiftUI

struct ListView: View {
    let list = ["Item1", "Item2", "Item3", "Item4", "Item5", "Item6", "Item7", "Item8"]
    
    var body: some View {
        List {
            ForEach(list, id: \.hash) { item in
                Text(item)
            }
        }
        .contextMenu(menuItems: {
            Group {
                Button(action: { print("Hello") }) {
                    VStack {
                        Image(systemName: "map.fill")
                        Text("Nearest")
                    }
                }
                Button(action: { print("Hello") }) {
                    VStack {
                        Image(systemName: "star.fill")
                        Text("Popular")
                    }
                }
                Button(action: { print("Hello") }) {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("Favorites")
                    }
                }
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
