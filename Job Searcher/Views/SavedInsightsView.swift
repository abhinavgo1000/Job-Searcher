//
//  SavedInsightsView.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/27/25.
//

import SwiftUI

struct SavedInsightsView: View {
    @State private var savedInsights: [JobInsights] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let api = InsightsAPI(baseURL: AppConfig.baseURL)
    
    var body: some View {
        Group {
            if isLoading && savedInsights.isEmpty {
                VStack { Spacer(); ProgressView("Loading saved insights…"); Spacer() }
            } else if let errorMessage = errorMessage {
                ContentUnavailableView(
                    "Couldn't load saved insights",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if savedInsights.isEmpty {
                ContentUnavailableView(
                    "No saved jobs",
                    systemImage: "tray",
                    description: Text("Save jobs from search to see them here.")
                )
            } else {
                List {
                    ForEach(savedInsights) { insight in
                        NavigationLink(value: insight) {
                            InsightRow(insight: insight)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await confirmAndUnsave(insight) }
                            } label: {
                                Label("Unsave", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Saved Insights")
        .task { await loadSavedJobs() }
        .refreshable { await refresh() }
        .navigationDestination(for: JobInsights.self) { insight in
            InsightView(insight: insight)
        }
    }
    
    private func loadSavedJobs() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let insights = try await api.fetchSavedInsights()
            savedInsights = insights
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refresh() async {
        await loadSavedJobs()
    }

    @MainActor
    private func confirmAndUnsave(_ insight: JobInsights) async {

        do {
            try await api.unsaveInsight(id: insight._id!)
            if let idx = savedInsights.firstIndex(of: insight) {
                withAnimation { _ = savedInsights.remove(at: idx) }
            }
        } catch {
            // Surface the error at top-level; user can pull-to-refresh to retry.
            errorMessage = error.localizedDescription
        }
    }
}
