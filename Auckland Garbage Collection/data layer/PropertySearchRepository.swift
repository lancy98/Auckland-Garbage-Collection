//
//  PropertySearchRepository.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 06/05/26.
//

import Foundation
import FirebaseFunctions

final class PropertySearchRepository {
    private let functions: Functions

    init(functions: Functions = Functions.functions()) {
        self.functions = functions
    }

    func searchProperty(query: String) async throws -> Any {
        let result = try await functions
            .httpsCallable("searchProperty")
            .call(["query": query])

        return result.data
    }
}
