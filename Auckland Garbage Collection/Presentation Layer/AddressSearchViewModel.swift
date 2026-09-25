//
//  AddressSearchViewModel.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 07/05/26.
//

import Foundation
import Observation

@Observable
final class AddressSearchViewModel {
    var searchText = ""
    private(set) var results: [PropertySearchResult] = []
    private(set) var isSearching = false
    private(set) var hasSearched = false
    private(set) var errorMessage: String?

    @ObservationIgnored
    private var requestID = UUID()

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

    func searchTextDidChange() async {
        await search(debounce: true)
    }

    func retrySearch() async {
        await search(debounce: false)
    }

    private func search(debounce: Bool) async {
        let currentRequestID = UUID()
        requestID = currentRequestID
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        results = []
        errorMessage = nil
        hasSearched = false
        isSearching = query.count >= 3
        guard isSearching else { return }

        defer {
            if requestID == currentRequestID {
                isSearching = false
            }
        }

        do {
            try Task.checkCancellation()
            if debounce {
                try await Task.sleep(for: .milliseconds(350))
            }
            let matches = try await propertySearchUseCase.searchProperty(query: query)
            try Task.checkCancellation()
            guard requestID == currentRequestID,
                  query == searchText.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            results = matches
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled, requestID == currentRequestID,
                  query == searchText.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            results = []
            errorMessage = String(localized: "Unable to search addresses. Please try again.")
        }

        hasSearched = true
    }
}
