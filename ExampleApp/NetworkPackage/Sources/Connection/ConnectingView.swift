//
//  ConnectingView.swift
//  Connection
//
//  Created by Yutaro Muta on 2024/06/03.
//

import SwiftUI
import Network
import UIKit

public struct ConnectingView: View {
    @State private var results: [NWBrowser.Result] = []
    @State private var hostTask: Task<Void, any Error>?
    @State private var cover: FullScreenCover? = nil

    public init() {}

    public var body: some View {
        List(results, id: \.self) { result in
            switch result.endpoint {
            case .service(let name, let type, let domain, _) where uuid != name:
                Button {
                    cover = .client(result)
                } label: {
                    Text("\(name)\(domain)\(type)")
                }
            default:
                Text("Unknown Endpoint")
            }
        }
        .navigationTitle("_example._udp")
        .toolbar {
            ToolbarItem {
                Button {
                    self.hostTask = Task {
                        guard let connection = try await host().first(where: { _ in true }) else {
                            return
                        }
                        cover = .host(connection)
                        hostTask = nil
                    }
                } label: {
                    Text("Host")
                }
                .disabled(hostTask != nil)
            }
        }
        .overlay {
            if results.isEmpty {
                ProgressView()
            }
        }
        .task {
            for await results in browse() {
                self.results = Array(results)
            }
        }
        .onDisappear {
            hostTask?.cancel()
        }
        .fullScreenCover(item: $cover) { cover in
            FullScreen(cover: cover)
        }
    }
}

extension ConnectingView {
    private var uuid: String {
        UIDevice().identifierForVendor?.uuidString ?? ""
    }

    private func host() -> AsyncThrowingStream<NWConnection, Error> {
        AsyncThrowingStream { continuation in
            do {
                let listener = try NWListener(using: .udp)
                listener.service = NWListener.Service(name: uuid, type: "_example._udp")
                listener.stateUpdateHandler = { state in
                    switch state {
                    case .failed(let error):
                        listener.cancel()
                        continuation.finish(throwing: error)
                    case .setup, .waiting, .ready, .cancelled:
                        break
                    @unknown default:
                        break
                    }
                }
                listener.newConnectionHandler = { connection in
                    continuation.yield(connection)
                }
                continuation.onTermination = { _ in
                    listener.cancel()
                }
                listener.start(queue: .main)
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    private func browse() -> AsyncStream<Set<NWBrowser.Result>> {
        AsyncStream { continuation in
            let browser = NWBrowser(
                for: .bonjour(
                    type: "_example._udp",
                    domain: nil
                ),
                using: .udp
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
                let services = results.filter {
                    switch $0.endpoint {
                    case .service:
                        return true
                    case .hostPort, .unix, .url, .opaque:
                        return false
                    @unknown default:
                        return false
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

extension ConnectingView {
    enum FullScreenCover: Identifiable {
        case host(NWConnection)
        case client(NWBrowser.Result)

        var id: Int {
            switch self {
            case .host(let connection):
                return connection.endpoint.hashValue
            case .client(let result):
                return result.hashValue
            }
        }
    }

    struct FullScreen: View {
        @Environment(\.dismiss) private var dismiss

        var cover: FullScreenCover

        var body: some View {
            NavigationStack {
                Group {
                    switch cover {
                    case .host(let connection):
                        ConnectedView(connection: connection, role: .host)
                    case .client(let result):
                        ConnectedView(endpoint: result.endpoint, role: .client)
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button {
                            dismiss()
                        } label: {
                            Text("Exit")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ConnectingView()
}

