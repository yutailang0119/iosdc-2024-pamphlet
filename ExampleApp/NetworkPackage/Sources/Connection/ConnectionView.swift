//
//  ConnectionView.swift
//  Connection
//
//  Created by Yutaro Muta on 2024/06/06.
//

import SwiftUI
import Network

struct ConnectionView: View {
    enum Role {
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
    private let role: Role
    @State private var data: ConnectionData

    init(connection: NWConnection, role: Role) {
        self.connection = connection
        self.role = role
        self.data = ConnectionData()
    }

    init(endpoint: NWEndpoint, role: Role) {
        self.connection = NWConnection(to: endpoint, using: .tcp)
        self.role = role
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
            switch role {
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
                        data.top.leading = role.territory
                    } label: {
                        data.top.leading
                    }
                    Button {
                        data.top.center = role.territory
                    } label: {
                        data.top.center
                    }
                    Button {
                        data.top.trailing = role.territory
                    } label: {
                        data.top.trailing
                    }
                }
                GridRow {
                    Button {
                        data.center.leading = role.territory
                    } label: {
                        data.center.leading
                    }
                    Button {
                        data.center.center = role.territory
                    } label: {
                        data.center.center
                    }
                    Button {
                        data.center.trailing = role.territory
                    } label: {
                        data.center.trailing
                    }
                }
                GridRow {
                    Button {
                        data.bottom.leading = role.territory
                    } label: {
                        data.bottom.leading
                    }
                    Button {
                        data.bottom.center = role.territory
                    } label: {
                        data.bottom.center
                    }
                    Button {
                        data.bottom.trailing = role.territory
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
        role: .client
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
