import Foundation
import Observation

@Observable
final class BinDatesViewModel {
    private(set) var collections: [BinCollection] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var hasError = false

    @ObservationIgnored
    private let repository = BinDatesRepository()

    @ObservationIgnored
    private var requestID = UUID()

    @ObservationIgnored
    private var currentPropertyID: String?

    func load(propertyId: String) async {
        let currentRequestID = UUID()
        requestID = currentRequestID
        if currentPropertyID != propertyId {
            collections = []
        }
        currentPropertyID = propertyId
        isLoading = true
        hasLoaded = false
        hasError = false

        defer {
            if requestID == currentRequestID {
                isLoading = false
            }
        }

        do {
            try Task.checkCancellation()
            let dates = try await repository.getAucklandBinDates(propertyId: propertyId)
            try Task.checkCancellation()
            guard requestID == currentRequestID else { return }
            collections = dates
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled, requestID == currentRequestID else { return }
            hasError = true
        }

        hasLoaded = true
    }
}
