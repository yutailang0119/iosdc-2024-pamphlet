//
//  AirPlayList.swift
//  NetworkLibrary
//
//  Created by Yutaro Muta on 2024/06/03.
//

import SwiftUI
import Network

struct AirPlayList: View {
    @State private var airplays: [String] = []

    var body: some View {
        List(airplays, id: \.self) {
            Text($0)
        }
        .navigationTitle("_airplay._tcp")
        .task {
            for await airplays in browse() {
                self.airplays = airplays
            }
        }
    }

    private func browse() -> AsyncStream<[String]> {
        AsyncStream { continuation in
            let browser = NWBrowser(
                for: .bonjour(
                    type: "_airplay._tcp",
                    domain: nil
                ),
                using: .tcp
            )
            browser.browseResultsChangedHandler = { results, _ in
                let services: [String] = results
                    .compactMap { result in
                        switch result.endpoint {
                        case .service(let name, let type, let domain, _):
                            return "\(name)\(domain)\(type)"
                        default:
                            return nil
                        }
                    }
                continuation.yield(services)
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
