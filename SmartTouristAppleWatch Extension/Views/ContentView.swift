//
//  ContentView.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 27/03/2020
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ListView().environmentObject(userData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
