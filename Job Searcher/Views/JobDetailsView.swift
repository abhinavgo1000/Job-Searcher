//
//  JobDetailsView.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/13/25.
//

import SwiftUI
import SafariServices

struct JobDetailsView: View {
    let job: JobPosting
    @State private var showingSafari = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(job.title).font(.title).bold()
                if let company = job.company { Text(company).font(.title3) }
                if let location = job.location { Label(location, systemImage: "mappin.and.ellipse") }

                Divider()

                if let desc = job.descriptionSnippet, !desc.isEmpty {
                    Text(desc)
                        .font(.body)
                        .textSelection(.enabled)
                } else {
                    Text("No description provided.")
                        .foregroundStyle(.secondary)
                }

                if let url = job.url {
                    Button {
                        showingSafari = true
                    } label: {
                        Label("Open original posting", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showingSafari) {
                        SafariView(url: URL(string: url)!)
                            .ignoresSafeArea()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { .init(url: url) }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
