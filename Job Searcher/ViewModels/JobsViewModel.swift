//
//  JobViewModel.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/14/25.
//

import Foundation

@MainActor
final class JobsViewModel: ObservableObject {
    @Published var query = JobQuery()                  // make sure JobQuery : Equatable
    @Published private(set) var jobs: [JobPosting] = []
    @Published private(set) var isLoading = false
    @Published private(set) var canLoadMore = true
    @Published var errorMessage: String?

    private let api: JobsAPI
    private var searchTask: Task<Void, Never>?

    init(api: JobsAPI) { self.api = api }

    // Called on appear and pull-to-refresh
    func refresh() {
        jobs.removeAll()
        canLoadMore = true
        query.page = 1                                  // requires JobQuery.page
        performSearch(debounceMillis: 0)
    }

    // Called by text fields/toggles and the “Load more” button
    func performSearch(debounceMillis: UInt64 = 300) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            // optional debounce to avoid spamming server while typing
            if debounceMillis > 0 {
                try? await Task.sleep(nanoseconds: debounceMillis * 1_000_000)
            }
            await self.fetch()
        }
    }

    // Infinite scroll helper
    func loadMoreIfNeeded(current item: JobPosting?) {
        guard let item, !isLoading, canLoadMore else { return }
        // when the cell is near the end, request next page (if server supports it)
        if let idx = jobs.firstIndex(of: item), idx >= jobs.count - 5 {
            query.page += 1
            performSearch(debounceMillis: 0)
        }
    }

    // MARK: - Private

    private func fetch() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await api.searchJobs(query: query)
            print("[VM] fetched \(result.count) jobs for page \(query.page)")

            if query.page == 1 {
                jobs = result
            } else {
                // de-dup on id
                let existing = Set(jobs.map(\.id))
                jobs.append(contentsOf: result.filter { !existing.contains($0.id) })
            }

            // if your backend supports page/page_size, this is a good heuristic
            canLoadMore = result.count >= query.pageSize
        } catch is CancellationError {
            // debounce cancellation — ignore
        } catch {
            errorMessage = error.localizedDescription
            canLoadMore = false
        }
        isLoading = false
    }
}
