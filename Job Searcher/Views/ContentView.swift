//
//  ContentView.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = JobsViewModel(api: JobsAPI(baseURL: AppConfig.baseURL))

    var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    searchBar
                    Divider()
                    resultsList
                }
                .navigationTitle("Job Search")
                .onAppear {
                    print("[ContentView] BaseURL =", AppConfig.baseURL.absoluteString)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            print("[ContentView] Manual search tapped")
                            vm.autoSearchEnabled = true            // enable live updates *after* first search
                            vm.refresh()
                        } label: {
                            Label("Search", systemImage: "magnifyingglass")
                                .font(.subheadline.bold())
                        }
                        .disabled(!vm.hasCriteria)
                        .buttonStyle(.bordered)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(vm.hasCriteria ? Color.blue : Color.gray) // ✅ blue when active, gray when disabled
                        .foregroundColor(.white)   // ✅ white text/icon
                        .clipShape(Capsule())
                    }
                }
            }
            .tint(.blue)                                   // ← makes back button blue
            .toolbarBackground(.visible, for: .navigationBar) // ensure bar is rendered
        }

        private var searchBar: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField("Role (e.g. Full Stack)", text: Binding(
                        get: { vm.query.q },
                        set: { vm.query.q = $0; vm.query.page = 1; vm.performSearch() }
                    ))
                    .textInputAutocapitalization(.never)

                    TextField("City (e.g. Bengaluru)", text: Binding(
                        get: { vm.query.city },
                        set: { vm.query.city = $0; vm.query.page = 1; vm.performSearch() }
                    ))
                    .textInputAutocapitalization(.never)
                }

                TextField("Workday filter (optional)", text: Binding(
                    get: { vm.query.workday },
                    set: { vm.query.workday = $0; vm.query.page = 1; vm.performSearch() }
                ))
                .textInputAutocapitalization(.never)

                HStack {
                    Toggle("Include Netflix", isOn: Binding(
                        get: { vm.query.includeNetflix },
                        set: { vm.query.includeNetflix = $0; vm.query.page = 1; vm.performSearch() }
                    ))
                    Toggle("Strict", isOn: Binding(
                        get: { vm.query.strict },
                        set: { vm.query.strict = $0; vm.query.page = 1; vm.performSearch() }
                    ))
                }

                if let error = vm.errorMessage {
                    Text(error).foregroundStyle(.red).font(.footnote)
                        .onAppear { print("[ContentView] Error:", error) }
                }
            }
            .padding()
            .background(.thinMaterial)
        }

    private var resultsList: some View {
        List {
            ForEach(vm.jobs) { job in
                NavigationLink(value: job) {
                    JobRow(job: job)
                        .onAppear { vm.loadMoreIfNeeded(current: job) }
                }
            }

            if vm.isLoading {
                HStack { Spacer(); ProgressView().padding(); Spacer() }
            } else if vm.jobs.isEmpty {
                ContentUnavailableView(
                    "No results",
                    systemImage: "magnifyingglass",
                    description: Text("Try changing your filters.")
                )
            } else if vm.canLoadMore {
                HStack {
                    Spacer()
                    Button("Load more") {
                        print("[ContentView] Load more tapped (next page \(vm.query.page + 1))")
                        vm.performSearch(debounceMillis: 0)
                    }
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: JobPosting.self) { job in
            JobDetailsView(job: job)
        }
        .refreshable {
            print("[ContentView] Pull-to-refresh")
            vm.refresh()
        }
    }
}

struct JobRow: View {
    let job: JobPosting
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title).font(.headline)
            HStack(spacing: 8) {
                Label(job.company!, systemImage: "building.2")
                if let location = job.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                }
                Label(job.source.capitalized, systemImage: "tray.full")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if let snippet = job.descriptionSnippet, !snippet.isEmpty {
                Text(snippet).font(.footnote).lineLimit(2)
            }
        }
        .padding(.vertical, 6)
    }
}


#Preview {
    ContentView()
}
