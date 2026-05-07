import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                filterBar
                Divider()

                if viewModel.searchText.isEmpty {
                    recentAndSuggestions
                } else if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                    noResults
                } else {
                    resultList
                }
            }
            .navigationTitle("Search")
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search your screenshots", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .onSubmit { viewModel.search(modelContext: modelContext) }
            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = ""; viewModel.searchResults = [] } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: viewModel.selectedFilter == nil) {
                    viewModel.selectedFilter = nil
                }
                ForEach(SearchFilter.allCases, id: \.self) { filter in
                    FilterChip(label: filter.rawValue, isSelected: viewModel.selectedFilter == filter) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var recentAndSuggestions: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Searches")
                            .font(.headline)
                        ForEach(viewModel.recentSearches, id: \.self) { search in
                            Button {
                                viewModel.searchText = search
                                viewModel.search(modelContext: modelContext)
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.secondary)
                                    Text(search)
                                    Spacer()
                                }
                                .font(.subheadline)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Filters")
                        .font(.headline)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        QuickFilterCard(icon: "lock.shield", label: "OTP Codes", filter: .otp)
                        QuickFilterCard(icon: "dollarsign.circle", label: "Amounts", filter: .amount)
                        QuickFilterCard(icon: "bag", label: "Shopping", filter: .shopping)
                        QuickFilterCard(icon: "doc.text", label: "Documents", filter: .document)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private var noResults: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No Results")
                .font(.headline)
            Text("Try different keywords or filters")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var resultList: some View {
        List(viewModel.searchResults) { item in
            ScreenshotRow(item: item)
        }
    }

    private func QuickFilterCard(icon: String, label: String, filter: SearchFilter) -> some View {
        Button {
            viewModel.selectedFilter = filter
            if !viewModel.searchText.isEmpty {
                viewModel.search(modelContext: modelContext)
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(label)
                    .font(.subheadline)
                Spacer()
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
