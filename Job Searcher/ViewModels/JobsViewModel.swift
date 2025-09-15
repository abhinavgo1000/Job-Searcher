//
//  JobViewModel.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/14/25.
//

import Foundation

@MainActor
final class JobsViewModel: ObservableObject {
    @Published var query = JobQuery()
    @Published private(set) var jobs: [JobPosting] = []
    @Published private(set) var isLoading = false
    @Published private(set) var canLoadMore = true
    @Published var errorMessage: String?

    /// Turn on if you want live search while typing *after* the first manual search.
    @Published var autoSearchEnabled = false

    private let api: JobsAPI
    private var searchTask: Task<Void, Never>?

    init(api: JobsAPI) { self.api = api }

    /// Decide when we consider the query “set”
    var hasCriteria: Bool {
        !query.q.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !query.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !query.workday.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Manual search (e.g., from a Search button)
    func refresh() {
        guard hasCriteria else {
            print("[VM] Skip refresh: no criteria")
            return
        }
        jobs.removeAll()
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

    func loadMoreIfNeeded(current item: JobPosting?) {
        guard hasCriteria, let item, !isLoading, canLoadMore else { return }
        if let idx = jobs.firstIndex(of: item), idx >= jobs.count - 5 {
            query.page += 1
            performSearch(debounceMillis: 0)
        }
    }

    private func fetch() async {
        guard hasCriteria else { return }
        isLoading = true
        errorMessage = nil
        do {
            let result = try await api.searchJobs(query: query)
            print("[VM] fetched \(result.count) jobs for page \(query.page)")
            if query.page == 1 { jobs = result }
            else {
                let existing = Set(jobs.map(\.id))
                jobs.append(contentsOf: result.filter { !existing.contains($0.id) })
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
