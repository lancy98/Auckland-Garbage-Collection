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

    func getAucklandBinDates(propertyId: String) async throws -> Any {
        let result = try await functions
            .httpsCallable("getAucklandBinDates")
            .call(["propertyId": propertyId])

        return result.data
    }
}
