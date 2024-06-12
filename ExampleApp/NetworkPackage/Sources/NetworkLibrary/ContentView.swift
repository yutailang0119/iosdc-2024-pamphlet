//
//  ContentView.swift
//  NetworkLibrary
//
//  Created by Yutaro Muta on 2024/06/02.
//

import SwiftUI
import PathMonitor
import Bonjour
import Connection

public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    PathMonitor.MonitorView()
                } label: {
                    Text("NWPathMonitor")
                }
                NavigationLink {
                    Bonjour.AirPlayList()
                } label: {
                    Text("NWBrowser")
                }
                NavigationLink {
                    Connection.EntryView()
                } label: {
                    Text("NWListener, NWConnection")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
