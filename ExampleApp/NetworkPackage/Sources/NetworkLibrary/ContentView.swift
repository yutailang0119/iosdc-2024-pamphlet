//
//  ContentView.swift
//  NetworkLibrary
//
//  Created by Yutaro Muta on 2024/06/02.
//

import SwiftUI
import BonjourExample
import UDPExample

public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    BonjourExample.AirPlayList()
                } label: {
                    Text("Bonjour Example")
                }
                NavigationLink {
                    UDPExample.EntryView()
                } label: {
                    Text("UDP Example")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
