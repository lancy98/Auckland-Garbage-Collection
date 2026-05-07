//
//  AddressSearchView.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 07/05/26.
//

import SwiftUI

@MainActor
struct AddressSearchView: View {
    @State private var viewModel = AddressSearchViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: geometry.size.height * 0.1)

                VStack(spacing: 14) {
                    Text("Find your address")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    Text("Enter your address to see your collection days.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)
                }

                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("Search for your address", text: $viewModel.searchText)
                        .font(.title3)
                }
                .padding(.horizontal, 18)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(.quaternary, lineWidth: 1)
                )
                .padding(.horizontal, 31)
                .padding(.top, 38)

                contentBelowSearchBar
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(.systemBackground))
            .task(id: viewModel.searchText) {
                await viewModel.searchTextDidChange()
            }
        }
    }

    @ViewBuilder
    private var contentBelowSearchBar: some View {
        if viewModel.results.isEmpty && !viewModel.isSearching && viewModel.errorMessage == nil {
            GeometryReader { imageGeometry in
                Image("AddressSearchIllustration")
                    .resizable()
                    .scaledToFill()
                    .accessibilityLabel(Text("Address search illustration"))
                    .frame(
                        width: imageGeometry.size.width,
                        height: imageGeometry.size.height,
                        alignment: .bottom
                    )
                    .clipped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 24)
        } else {
            searchResultsContent
                .padding(.horizontal, 31)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    @ViewBuilder
    private var searchResultsContent: some View {
        if viewModel.isSearching {
            HStack(spacing: 10) {
                ProgressView()
                Text("Searching addresses...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(resultsBackground)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(resultsBackground)
        } else if !viewModel.results.isEmpty {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.results) { result in
                        Text(result.address)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        if result.id != viewModel.results.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(resultsBackground)
        }
    }

    private var resultsBackground: some View {
        RoundedRectangle(cornerRadius: 13, style: .continuous)
            .fill(.background)
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            )
    }
}

#Preview {
    AddressSearchView()
}
