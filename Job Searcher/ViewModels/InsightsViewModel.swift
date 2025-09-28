//
//  InsightsViewModel.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/27/25.
//

import Foundation

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var query = InsightsQuery()
    @Published private(set) var insights: [JobInsights] = []
    @Published private(set) var isLoading = false
    @Published private(set) var canLoadMore = true
    @Published var errorMessage: String?
    
    /// Turn on if you want live search while typing *after* the first manual search.
    @Published var autoSearchEnabled = false
    
    private let api: InsightsAPI
    private var searchTask: Task<Void, Never>?

    init(api: InsightsAPI) {
        self.api = api
        self.insights = []
    }
    
    /// Decide when we consider the query “set”
    var hasCriteria: Bool {
        let hasPosition = !query.position.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasCompanies = query.companies.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return hasPosition || hasCompanies
    }
    
    /// Manual search (e.g., from a Search button)
    func refresh() {
        guard hasCriteria else {
            print("[VM] Skip refresh: no criteria")
            return
        }
        insights = []
        canLoadMore = true
        query.page = 1
        performSearch(debounceMillis: 0)
    }
    
    /// Called by text fields/toggles; only fires if autoSearchEnabled and criteria exist
    func performSearch(debounceMillis: UInt64 = 300) {
        guard autoSearchEnabled, hasCriteria else {
            // not enabled or no criteria yet
            return
        }
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            if debounceMillis > 0 { try? await Task.sleep(nanoseconds: debounceMillis * 1_000_000) }
            await self.fetch()
        }
    }

    func loadMoreIfNeeded(current item: JobInsights?) {
        guard hasCriteria, let item, !isLoading, canLoadMore else { return }
        if let idx = insights.firstIndex(of: item), idx >= insights.count - 5 {
            query.page += 1
            performSearch(debounceMillis: 0)
        }
    }

    private func fetch() async {
        guard hasCriteria else { return }
        isLoading = true
        errorMessage = nil
        do {
            let result = try await api.searchInsights(query: query)
            print("[VM] fetched \(result.count) insights for page \(query.page)")
            if query.page == 1 {
                insights = result
            } else {
                let existing = Set(insights.map(\.id))
                let newOnes = result.filter { !existing.contains($0.id) }
                insights.append(contentsOf: newOnes)
            }
            canLoadMore = result.count >= query.pageSize
        } catch is CancellationError {
            // ignore
        } catch {
            errorMessage = error.localizedDescription
            canLoadMore = false
        }
        isLoading = false
    }
}
