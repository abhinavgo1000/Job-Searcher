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
    @Published var errorMessage: String?
    @Published private(set) var canLoadMore = true

    private let api: JobsAPI
    private var searchTask: Task<Void, Never>?
    private var inFlightToken: CancellationToken?

    init(api: JobsAPI) {
        self.api = api
    }

    func onAppear() {
        if jobs.isEmpty { refresh() }
    }

    func refresh() {
        jobs.removeAll()
        canLoadMore = true
        query.page = 1
        performSearch(debounceMillis: 0)
    }

    func performSearch(debounceMillis: UInt64 = 300) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            // debounce
            try? await Task.sleep(nanoseconds: debounceMillis * 1_000_000)
            await self.fetch(resetIfNeeded: false)
        }
    }

    func loadMoreIfNeeded(current item: JobPosting?) {
        guard let item, canLoadMore, !isLoading else { return }
        let thresholdIndex = jobs.index(jobs.endIndex, offsetBy: -5)
        if let idx = jobs.firstIndex(of: item), idx >= thresholdIndex {
            query.page += 1
            performSearch(debounceMillis: 0)
        }
    }

    private func fetch(resetIfNeeded: Bool) async {
        isLoading = true
        errorMessage = nil
        inFlightToken?.cancel()
        let token = CancellationToken()
        inFlightToken = token
        do {
            let new = try await api.searchJobs(query: query, cancellationToken: token)
            if query.page == 1 {
                jobs = new
            } else {
                // de-dupe by id
                let existing = Set(jobs.map(\.id))
                jobs.append(contentsOf: new.filter { !existing.contains($0.id) })
            }
            canLoadMore = new.count >= query.pageSize
        } catch is CancellationError {
            // ignore
        } catch {
            errorMessage = error.localizedDescription
            canLoadMore = false
        }
        isLoading = false
    }
}

