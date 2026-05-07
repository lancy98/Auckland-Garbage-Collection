//
//  PropertySearchRepositoryProtocol.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 07/05/26.
//

protocol PropertySearchRepositoryProtocol {
    func searchProperty(query: String) async throws -> [PropertySearchResult]
}
