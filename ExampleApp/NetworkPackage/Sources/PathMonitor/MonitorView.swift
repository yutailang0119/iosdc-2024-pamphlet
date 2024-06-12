//
//  MonitorView.swift
//  PathMonitor
//
//  Created by Yutaro Muta on 2024/06/13.
//

import SwiftUI
import Network

public struct MonitorView: View {
    @State private var path: NWPath?

    public init() {}

    public var body: some View {
        Group {
            switch path?.status {
            case .satisfied:
                Text("satisfied")
                    .font(.title)
                    .foregroundStyle(.green)
            case .unsatisfied:
                VStack {
                    Text("unsatisfied")
                        .font(.title)
                        .foregroundStyle(.red)
                    HStack {
                        Text("unsatisfiedReason > ")
                        switch path?.unsatisfiedReason {
                        case .notAvailable:
                            Text("notAvailable")
                        case .cellularDenied:
                            Text("cellularDenied")
                        case .wifiDenied:
                            Text("wifiDenied")
                        case .localNetworkDenied:
                            Text("localNetworkDenied")
                        case .vpnInactive:
                            Text("vpnInactive")
                        default:
                            EmptyView()
                        }
                    }
                }
            case .requiresConnection:
                Text("requiresConnection")
                    .font(.title)
                    .foregroundStyle(.yellow)
            case nil:
                ProgressView()
            @unknown default:
                ContentUnavailableView("Unknown", systemImage: "exclamationmark.circle")
            }
        }
        .navigationTitle("NWPathMonitor")
        .task {
            for await path in monitor() {
                self.path = path
            }
        }
    }

    private func monitor() -> AsyncStream<NWPath> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                continuation.yield(path)
            }
            continuation.onTermination = { _ in
                monitor.cancel()
            }
            monitor.start(queue: .main)
        }
    }
}

#Preview {
    MonitorView()
}

