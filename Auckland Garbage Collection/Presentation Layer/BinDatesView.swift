import SwiftUI

struct BinDatesView: View {
    let property: PropertySearchResult

    @State private var viewModel = BinDatesViewModel()

    private var collectionDays: [[BinCollection]] {
        let grouped = Dictionary(grouping: viewModel.collections, by: \.date)
        return grouped.keys.sorted().compactMap { grouped[$0] }
    }

    private var councilURL: URL {
        URL(string: "https://experience.aucklandcouncil.govt.nz/rubbish-recycling-collection-days/")!
            .appendingPathComponent("\(property.id).html")
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Your address", systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(property.address)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0))

            if viewModel.collections.isEmpty {
                collectionStatus
            } else {
                if viewModel.hasError {
                    Section {
                        Label("Couldn’t refresh these dates. Pull down to try again.", systemImage: "exclamationmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                ForEach(collectionDays, id: \.first?.date) { collections in
                    if let first = collections.first {
                        Section {
                            ForEach(collections) { collection in
                                CollectionRow(collection: collection)
                            }
                        } header: {
                            VStack(alignment: .leading, spacing: 6) {
                                if first.date == collectionDays.first?.first?.date {
                                    Text("Next collection")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                }
                                Text(first.formattedDate)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.primary)
                            }
                            .textCase(nil)
                            .padding(.bottom, 8)
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }

            Section {
                Link(destination: councilURL) {
                    HStack {
                        Text("View on Auckland Council")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.footnote.weight(.semibold))
                    }
                }
            } footer: {
                Text("Collection information is provided by Auckland Council.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Collection days")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.load(propertyId: property.id)
        }
        .task(id: property.id) {
            await viewModel.load(propertyId: property.id)
        }
    }

    @ViewBuilder
    private var collectionStatus: some View {
        if viewModel.isLoading || !viewModel.hasLoaded {
            Section {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Loading collection days…")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
            }
        } else {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text(viewModel.hasError
                             ? LocalizedStringKey("Unable to load collection days")
                             : LocalizedStringKey("No collection days found"))
                    } icon: {
                        Image(systemName: viewModel.hasError ? "exclamationmark.circle" : "calendar")
                    }
                    .font(.headline)

                    Text(viewModel.hasError
                         ? LocalizedStringKey("Please try again, or check this address on Auckland Council’s website.")
                         : LocalizedStringKey("Check Auckland Council’s website for information about this address."))
                        .foregroundStyle(.secondary)

                    if viewModel.hasError {
                        Button("Try Again") {
                            Task { await viewModel.load(propertyId: property.id) }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

private struct CollectionRow: View {
    let collection: BinCollection

    private var tint: Color {
        switch collection.kind {
        case .rubbish: .secondary
        case .recycling: .orange
        case .foodScraps: .green
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: collection.kind.symbol)
                .font(.title3.weight(.medium))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)

            Text(collection.kind.title)
                .font(.body.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}
