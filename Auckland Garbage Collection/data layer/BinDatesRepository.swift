//
//  BinDatesRepository.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 06/05/26.
//

import Foundation
import FirebaseFunctions

final class BinDatesRepository {
    private let functions: Functions

    init(functions: Functions = Functions.functions()) {
        self.functions = functions
    }

    func getAucklandBinDates(propertyId: String) async throws -> [BinCollection] {
        let result = try await functions
            .httpsCallable("getAucklandBinDates")
            .call(["propertyId": propertyId])

        guard JSONSerialization.isValidJSONObject(result.data) else {
            throw BinDatesError.invalidResponse
        }

        let data = try JSONSerialization.data(withJSONObject: result.data)
        let response = try JSONDecoder().decode(BinDatesResponse.self, from: data)
        return response.collections.sorted { $0.date < $1.date }
    }
}

private struct BinDatesResponse: Decodable {
    let collections: [BinCollection]
}

private enum BinDatesError: Error {
    case invalidResponse
}
