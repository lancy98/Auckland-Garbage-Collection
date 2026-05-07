//
//  PropertySearchRepository.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 06/05/26.
//

import Foundation
import FirebaseFunctions

final class PropertySearchRepository: PropertySearchRepositoryProtocol {
    private let functions: Functions

    init(functions: Functions = Functions.functions()) {
        self.functions = functions
    }

    func searchProperty(query: String) async throws -> [PropertySearchResult] {
        let result = try await functions
            .httpsCallable("searchProperty")
            .call(["query": query])

        return mapSearchResults(from: result.data)
    }

    private func mapSearchResults(from data: Any) -> [PropertySearchResult] {
        let records: [[String: Any]]

        if let array = data as? [[String: Any]] {
            records = array
        } else if let dictionary = data as? [String: Any] {
            records = dictionaryArray(from: dictionary)
        } else {
            records = []
        }

        return records.compactMap(makeSearchResult)
    }

    private func dictionaryArray(from dictionary: [String: Any]) -> [[String: Any]] {
        let candidateKeys = ["results", "properties", "items", "data"]

        for key in candidateKeys {
            if let array = dictionary[key] as? [[String: Any]] {
                return array
            }
        }

        return [dictionary]
    }

    private func makeSearchResult(from dictionary: [String: Any]) -> PropertySearchResult? {
        guard let address = firstString(
            in: dictionary,
            keys: ["address", "fullAddress", "displayAddress", "label", "text", "description"]
        ) else {
            return nil
        }

        let id = firstString(
            in: dictionary,
            keys: ["propertyId", "id", "value", "property_id", "objectId"]
        ) ?? address

        return PropertySearchResult(id: id, address: address)
    }

    private func firstString(in dictionary: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = dictionary[key] as? String, !value.isEmpty {
                return value
            }

            if let value = dictionary[key] as? CustomStringConvertible {
                let string = value.description
                if !string.isEmpty {
                    return string
                }
            }
        }

        return nil
    }
}
