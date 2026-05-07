//
//  PropertySearchUseCase.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 07/05/26.
//

protocol PropertySearchUseCaseProtocol {
    func searchProperty(query: String) async throws -> [PropertySearchResult]
}

struct PropertySearchUseCase: PropertySearchUseCaseProtocol {
    let repository: any PropertySearchRepositoryProtocol
    
    func searchProperty(query: String) async throws -> [PropertySearchResult] {
        try await repository.searchProperty(query: query)
    }
}
