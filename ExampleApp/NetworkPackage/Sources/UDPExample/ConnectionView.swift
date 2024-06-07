//
//  ConnectionView.swift
//  UDPExample
//
//  Created by Yutaro Muta on 2024/06/06.
//

import SwiftUI
import Network

struct ConnectionView: View {
    enum Player {
        case host
        case client

        var territory: ConnectionData.Row.Item {
            switch self {
            case .host: .host
            case .client: .client
            }
        }
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let connection: NWConnection
    private let player: Player
    @State private var data: ConnectionData

    init(connection: NWConnection, player: Player) {
        self.connection = connection
        self.player = player
        self.data = ConnectionData()
    }

    init(endpoint: NWEndpoint, player: Player) {
        self.connection = NWConnection(to: endpoint, using: .udp)
        self.player = player
        self.data = ConnectionData()

        connection.send(
            content: try? encoder.encode(ConnectionData()),
            completion: .contentProcessed { error in
                print(error)
            }
        )
    }

    public var body: some View {
        VStack {
            switch player {
            case .host:
                Text("Host")
                    .foregroundStyle(.blue)
            case .client:
                Text("Client")
                    .foregroundStyle(.red)
            }
            Grid {
                GridRow {
                    Button {
                        data.top.leading = player.territory
                    } label: {
                        data.top.leading
                    }
                    Button {
                        data.top.center = player.territory
                    } label: {
                        data.top.center
                    }
                    Button {
                        data.top.trailing = player.territory
                    } label: {
                        data.top.trailing
                    }
                }
                GridRow {
                    Button {
                        data.center.leading = player.territory
                    } label: {
                        data.center.leading
                    }
                    Button {
                        data.center.center = player.territory
                    } label: {
                        data.center.center
                    }
                    Button {
                        data.center.trailing = player.territory
                    } label: {
                        data.center.trailing
                    }
                }
                GridRow {
                    Button {
                        data.bottom.leading = player.territory
                    } label: {
                        data.bottom.leading
                    }
                    Button {
                        data.bottom.center = player.territory
                    } label: {
                        data.bottom.center
                    }
                    Button {
                        data.bottom.trailing = player.territory
                    } label: {
                        data.bottom.trailing
                    }
                }
            }
        }
        .padding()
        .onChange(of: data) { _, newValue in
            connection.send(
                content: try? encoder.encode(newValue),
                completion: .contentProcessed { error in
                    print(error)
                }
            )
        }
        .task {
            do {
                for try await message in receiveMessages() {
                    let data = try decoder.decode(ConnectionData.self, from: message)
                    self.data = data
                }
            } catch {
                print(error)
            }
        }
        .onDisappear {
            connection.cancel()
        }
    }
}

extension ConnectionView {
    private func receiveMessages() -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            func receiveMessage() {
                connection.receiveMessage { content, contentContext, isComplete, error in
                    if let content {
                        continuation.yield(content)
                        receiveMessage()
                    } else if let error {
                        print(error)
                        connection.cancel()
                    }
                }
            }

            connection.stateUpdateHandler = { state in
                switch state {
                case .setup, .waiting, .preparing, .ready, .cancelled:
                    break
                case .failed(let error):
                    connection.cancel()
                    continuation.finish(throwing: error)
                @unknown default:
                    break
                }
            }
            receiveMessage()
            connection.start(queue: .main)
        }
    }
}

#Preview {
    ConnectionView(
        endpoint: NWEndpoint.service(
            name: "ENDPOINT_NAME",
            type: "_example._udp",
            domain: "local.",
            interface: nil
        ),
        player: .client
    )
}

extension ConnectionData.Row.Item: View {
    var body: some View {
        Group {
            switch self {
            case .empty:
                Color.clear
                    .border(.gray)
            case .host:
                Color.blue
            case .client:
                Color.red
            }
        }
        .scaledToFit()
    }
}
