//
//  SavedJobsView.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/24/25.
//

import SwiftUI

struct SavedJobsView: View {
    @State private var savedJobs: [JobPosting] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    private let api = JobsAPI(baseURL: AppConfig.baseURL)

    var body: some View {
        Group {
            if isLoading && savedJobs.isEmpty {
                VStack { Spacer(); ProgressView("Loading saved jobs…"); Spacer() }
            } else if let errorMessage = errorMessage {
                ContentUnavailableView(
                    "Couldn't load saved jobs",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if savedJobs.isEmpty {
                ContentUnavailableView(
                    "No saved jobs",
                    systemImage: "tray",
                    description: Text("Save jobs from search to see them here.")
                )
            } else {
                List {
                    ForEach(savedJobs) { job in
                        NavigationLink(value: job) {
                            JobRow(job: job)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await confirmAndUnsave(job) }
                            } label: {
                                Label("Unsave", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Saved Jobs")
        .task { await loadSavedJobs() }
        .refreshable { await refresh() }
        .navigationDestination(for: JobPosting.self) { job in
            JobDetailsView(job: job)
        }
    }

    private func loadSavedJobs() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let jobs = try await api.fetchSavedJobs()
            savedJobs = jobs
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refresh() async {
        await loadSavedJobs()
    }

    @MainActor
    private func confirmAndUnsave(_ job: JobPosting) async {

        do {
            try await api.unsaveJob(id: job._id!)
            if let idx = savedJobs.firstIndex(of: job) {
                withAnimation { _ = savedJobs.remove(at: idx) }
            }
        } catch {
            // Surface the error at top-level; user can pull-to-refresh to retry.
            errorMessage = error.localizedDescription
        }
    }
}

