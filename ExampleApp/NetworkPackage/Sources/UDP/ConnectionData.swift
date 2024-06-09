//
//  ConnectionData.swift
//  UDP
//
//  Created by Yutaro Muta on 2024/06/06.
//

import Foundation

struct ConnectionData: Equatable, Codable {
    struct Row: Equatable, Codable {
        enum Item: Equatable, Codable {
            case empty
            case host
            case client
        }

        var leading: Item
        var center: Item
        var trailing: Item
    }

    var top: Row
    var center: Row
    var bottom: Row

    init() {
        self.top = Row(leading: .empty, center: .empty, trailing: .empty)
        self.center = Row(leading: .empty, center: .empty, trailing: .empty)
        self.bottom = Row(leading: .empty, center: .empty, trailing: .empty)
    }
}
