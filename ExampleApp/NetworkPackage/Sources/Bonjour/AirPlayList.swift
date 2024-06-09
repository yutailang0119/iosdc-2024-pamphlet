//
//  AirPlayList.swift
//  Bonjour
//
//  Created by Yutaro Muta on 2024/06/03.
//

import SwiftUI
import Network

public struct AirPlayList: View {
    @State private var airplays: [String] = []

    public init() {}

    public var body: some View {
        List(airplays, id: \.self) {
            Text($0)
        }
        .navigationTitle("_airplay._tcp")
        .task {
            for await airplays in browse() {
                self.airplays = airplays.compactMap {
                    switch $0.endpoint {
                    case .service(let name, let type, let domain, _):
                        return "\(name)\(domain)\(type)"
                    case .hostPort, .unix, .url, .opaque:
                        return nil
                    @unknown default:
                        return nil
                    }
                }
            }
        }
    }

    private func browse() -> AsyncStream<Set<NWBrowser.Result>> {
        AsyncStream { continuation in
            let browser = NWBrowser(
                for: .bonjour(
                    type: "_airplay._tcp",
                    domain: nil
                ),
                using: .tcp
            )
            browser.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    continuation.yield(browser.browseResults)
                case .failed:
                    browser.cancel()
                    continuation.finish()
                case .setup, .cancelled, .waiting:
                    break
                @unknown default:
                    break
                }
            }
            browser.browseResultsChangedHandler = { results, _ in
                continuation.yield(results)
            }
            continuation.onTermination = { _ in
                browser.cancel()
            }
            browser.start(queue: .main)
        }
    }
}

#Preview {
    AirPlayList()
}
