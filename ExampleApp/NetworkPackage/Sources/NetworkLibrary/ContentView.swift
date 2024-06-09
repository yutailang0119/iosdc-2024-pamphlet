//
//  ContentView.swift
//  NetworkLibrary
//
//  Created by Yutaro Muta on 2024/06/02.
//

import SwiftUI
import Bonjour
import UDP

public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    Bonjour.AirPlayList()
                } label: {
                    Text("Bonjour example")
                }
                NavigationLink {
                    UDP.EntryView()
                } label: {
                    Text("UDP example")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
