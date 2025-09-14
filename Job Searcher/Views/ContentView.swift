//
//  ContentView.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = JobsViewModel(
        api: JobsAPI(baseURL: AppConfig.baseURL)
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                Divider()
                resultsList
            }
            .navigationTitle("Job Search")
            .onAppear { vm.onAppear() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.refresh()
                    } label: { Image(systemName: "arrow.clockwise") }
                        .disabled(vm.isLoading)
                }
            }
        }
    }

    private var searchBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Role (e.g. Full Stack)", text: Binding(
                    get: { vm.query.q },
                    set: { vm.query.q = $0; vm.performSearch() }
                ))
                .textInputAutocapitalization(.never)

                TextField("City (e.g. Bengaluru)", text: Binding(
                    get: { vm.query.city },
                    set: { vm.query.city = $0; vm.performSearch() }
                ))
                .textInputAutocapitalization(.never)
            }

            TextField("Workday filter (optional)", text: Binding(
                get: { vm.query.workday },
                set: { vm.query.workday = $0;vm.performSearch() }
            ))
            .textInputAutocapitalization(.never)

            HStack {
                Toggle("Include Netflix", isOn: Binding(
                    get: { vm.query.includeNetflix },
                    set: { vm.query.includeNetflix = $0; vm.performSearch() }
                ))
                Toggle("Strict", isOn: Binding(
                    get: { vm.query.strict },
                    set: { vm.query.strict = $0; vm.performSearch() }
                ))
            }

            if let error = vm.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
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
                HStack {
                    Spacer()
                    ProgressView().padding()
                    Spacer()
                }
            } else if vm.canLoadMore {
                HStack {
                    Spacer()
                    Button("Load more") { vm.performSearch(debounceMillis: 0) }
                    Spacer()
                }
            } else if vm.jobs.isEmpty {
                ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Try changing your filters."))
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: JobPosting.self) { job in
            JobDetailsView(job: job)
        }
    }
}

struct JobRow: View {
    let job: JobPosting

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title).font(.headline)
            HStack(spacing: 8) {
                if let company = job.company, !company.isEmpty {
                    Label(company, systemImage: "building.2")
                }
                if let location = job.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                }
                if let source = job.source, !source.isEmpty {
                    Label(source.capitalized, systemImage: "tray.full")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
}
