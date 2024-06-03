//
//  ContentView.swift
//  NetworkLibrary
//
//  Created by Yutaro Muta on 2024/06/02.
//

import SwiftUI
import BonjourExample

public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    AirPlayList()
                } label: {
                    Text("_airplay._tcp")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
