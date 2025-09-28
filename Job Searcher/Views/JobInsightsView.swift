//
//  JobDetailsView.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/19/25.
//

import SwiftUI

struct JobInsightsView: View {
    @StateObject private var vm = InsightsViewModel(api: InsightsAPI(baseURL: AppConfig.baseURL))
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Divider()
            resultsList
        }
        .navigationTitle("Job Insights")
        .onAppear {
            print("[InsightsView] BaseURL =", AppConfig.baseURL.absoluteString)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("[InsightsView] Manual search tapped")
                    vm.autoSearchEnabled = true            // enable live updates *after* first search
                    vm.refresh()
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                        .font(.subheadline.bold())
                }
                .disabled(!vm.hasCriteria)
                .buttonStyle(.automatic)
                .background(vm.hasCriteria ? Color.blue : Color.gray) // ✅ blue when active, gray when disabled
                .foregroundColor(.white)   // ✅ white text/icon
                .clipShape(Capsule())
            }
        }
        .tint(.blue)                                   // ← makes back button blue
        .toolbarBackground(.visible, for: .navigationBar) // ensure bar is rendered
    }
    
    private var searchBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Role (e.g. Full Stack)", text: Binding(
                    get: { vm.query.position },
                    set: { vm.query.position = $0; vm.query.page = 1; vm.performSearch() }
                ))
                .textInputAutocapitalization(.never)

                TextField("Companies (comma-separated)", text: Binding(
                    get: { vm.query.companies.joined(separator: ", ") },
                    set: { newValue in
                        let parts = newValue
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        vm.query.companies = parts
                        vm.query.page = 1
                        vm.performSearch()
                    }
                ))
                .textInputAutocapitalization(.never)
            }

            Stepper(
                "Years Experience: \(vm.query.yearsExperience)",
                value: Binding(
                    get: { vm.query.yearsExperience },
                    set: { vm.query.yearsExperience = $0; vm.query.page = 1; vm.performSearch() }
                ),
                in: 0...50
            )

            Toggle("Remote only", isOn: Binding(
                get: { vm.query.remote },
                set: { vm.query.remote = $0; vm.query.page = 1; vm.performSearch() }
            ))

            if let error = vm.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
                    .onAppear { print("[InsightsView] Error:", error) }
            }
        }
        .padding()
        .background(.thinMaterial)
    }

    private var resultsList: some View {
        List {
            ForEach(vm.insights) { insight in
                InsightRow(insight: insight)
                    .onAppear { vm.loadMoreIfNeeded(current: insight) }
            }

            if vm.isLoading {
                HStack { Spacer(); ProgressView().padding(); Spacer() }
            } else if vm.insights.isEmpty {
                ContentUnavailableView(
                    "No insights",
                    systemImage: "magnifyingglass",
                    description: Text("Try changing your filters.")
                )
            } else if vm.canLoadMore {
                HStack {
                    Spacer()
                    Button("Load more") {
                        print("[InsightsView] Load more tapped (next page \(vm.query.page + 1))")
                        vm.performSearch(debounceMillis: 0)
                    }
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            print("[InsightsView] Pull-to-refresh")
            vm.refresh()
        }
    }
}

struct InsightRow: View {
    @State private var isSaving = false
    @State private var showSaveAlert = false
    @State private var saveAlertTitle: String = ""
    @State private var saveAlertMessage: String? = nil
    
    let insight: JobInsights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let feedback = insight.feedback, !feedback.isEmpty {
                Text(feedback)
                    .font(.headline)
            }
            
            if !insight.skills.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Skills")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(insight.skills, id: \.self) { skill in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(skill.name)
                                        .font(.subheadline).bold()
                                    Text(skill.proficiencyLevel)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let category = skill.category, !category.isEmpty {
                                        Text(category)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    if let summary = insight.summary, !summary.isEmpty {
                        Text(summary)
                            .font(.footnote)
                    }
                    Button {
                        Task {
                            isSaving = true
                            defer { isSaving = false }
                            let api = InsightsAPI(baseURL: AppConfig.baseURL)
                            do {
                                let saved = try await api.saveInsight(insight: insight)
                                saveAlertTitle = "Saved"
                                if let saved = saved {
                                    let feedbackText = saved.feedback ?? ""
                                    saveAlertMessage = "Insight saved successfully: \(feedbackText)."
                                } else {
                                    saveAlertMessage = "Insight saved successfully."
                                }
                            } catch {
                                saveAlertTitle = "Save Failed"
                                saveAlertMessage = error.localizedDescription
                            }
                            showSaveAlert = true
                        }
                    } label: {
                        Label(isSaving ? "Saving…" : "Save Insight", systemImage: isSaving ? "hourglass" : "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(isSaving)
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                    
                }
            }
        }
        .padding(.vertical, 6)
    }
}

