//
//  PropertySearchResult.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 07/05/26.
//

import Foundation

struct PropertySearchResult: Identifiable, Hashable, Sendable {
    let id: String
    let address: String

    init(id: String, address: String) {
        self.id = id
        self.address = address
    }
}
