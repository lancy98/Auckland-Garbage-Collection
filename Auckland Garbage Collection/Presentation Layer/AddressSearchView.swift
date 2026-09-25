import SwiftUI

struct AddressSearchView: View {
    @State private var viewModel = AddressSearchViewModel()
    @State private var isSearchPresented = false

    private var query: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.results.isEmpty {
                    Section {
                        ForEach(viewModel.results) { result in
                            NavigationLink(value: result) {
                                AddressResultRow(address: result.address)
                            }
                            .accessibilityHint("Show collection days for this address")
                        }
                    } header: {
                        Text("Matching addresses")
                    } footer: {
                        Text("Choose an address to see its collection days.")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .overlay {
                if viewModel.results.isEmpty {
                    searchStatus
                }
            }
            .navigationTitle("Collections")
            .searchable(
                text: $viewModel.searchText,
                isPresented: $isSearchPresented,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search your address"
            )
            .autocorrectionDisabled()
            .navigationDestination(for: PropertySearchResult.self) { property in
                BinDatesView(property: property)
            }
            .task(id: viewModel.searchText) {
                await viewModel.searchTextDidChange()
            }
        }
    }

    @ViewBuilder
    private var searchStatus: some View {
        if query.isEmpty && !isSearchPresented {
            welcomeContent
        } else if query.count < 3 {
            ContentUnavailableView {
                Label("Find your address", systemImage: "mappin.and.ellipse")
            } description: {
                Text("Enter your house number and street name. Use at least three characters.")
            }
        } else if viewModel.isSearching || !viewModel.hasSearched {
            ProgressView("Searching addresses…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.errorMessage != nil {
            ContentUnavailableView {
                Label("Unable to search", systemImage: "exclamationmark.circle")
            } description: {
                Text("Please try again in a moment.")
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.retrySearch() }
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            ContentUnavailableView.search(text: query)
        }
    }

    private var welcomeContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 42, weight: .regular))
                    .foregroundStyle(.green)
                    .frame(width: 96, height: 96)
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text("Your next collection,\nat a glance.")
                        .font(.title2.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Find rubbish, recycling and food scraps collection days for your Auckland address.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .multilineTextAlignment(.center)

                Button {
                    isSearchPresented = true
                } label: {
                    Text("Find My Address")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .frame(maxWidth: 340)
            .padding(.horizontal, 28)
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct AddressResultRow: View {
    let address: String

    private var addressParts: [String] {
        address.split(separator: ",", maxSplits: 1).map {
            $0.trimmingCharacters(in: .whitespaces)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(addressParts.first ?? address)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                if addressParts.count > 1 {
                    Text(addressParts[1])
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AddressSearchView()
}
