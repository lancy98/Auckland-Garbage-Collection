//
//  AddressSearchViewModel.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 07/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AddressSearchViewModel {
    var searchText = ""
    private(set) var results: [PropertySearchResult] = []
    private(set) var isSearching = false
    private(set) var errorMessage: String?

    @ObservationIgnored
    private let propertySearchUseCase: any PropertySearchUseCaseProtocol

    init() {
        self.propertySearchUseCase = PropertySearchUseCase(
            repository: PropertySearchRepository()
        )
    }

    init(propertySearchUseCase: any PropertySearchUseCaseProtocol) {
        self.propertySearchUseCase = propertySearchUseCase
    }

    func searchTextDidChange() async  {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 3 else {
            results = []
            isSearching = false
            errorMessage = nil
            return
        }
        
        try? await Task.sleep(for: .milliseconds(350))
        guard !Task.isCancelled else { return }
        await search(query: query)
    }

    private func search(query: String) async {
        isSearching = true
        errorMessage = nil

        do {
            results = try await propertySearchUseCase.searchProperty(query: query)
        } catch {
            results = []
            errorMessage = String(localized: "Unable to search addresses. Please try again.")
        }

        isSearching = false
    }
}
