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
    @State private var isSaving = false
    @State private var showSaveAlert = false
    @State private var saveAlertTitle: String = ""
    @State private var saveAlertMessage: String? = nil

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
                    .buttonStyle(.bordered)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .sheet(isPresented: $showingSafari) {
                        SafariView(url: URL(string: url)!)
                            .ignoresSafeArea()
                    }
                }
                Button {
                    Task {
                        isSaving = true
                        defer { isSaving = false }
                        let api = JobsAPI(baseURL: AppConfig.baseURL)
                        do {
                            let saved = try await api.saveJob(job: job)
                            saveAlertTitle = "Saved"
                            if let saved = saved {
                                let companyText = saved.company ?? ""
                                saveAlertMessage = companyText.isEmpty ? "Saved \(saved.title)." : "Saved \(saved.title) at \(companyText)."
                            } else {
                                saveAlertMessage = "Job saved successfully."
                            }
                        } catch {
                            saveAlertTitle = "Save Failed"
                            saveAlertMessage = error.localizedDescription
                        }
                        showSaveAlert = true
                    }
                } label: {
                    Label(isSaving ? "Saving…" : "Save Job Posting", systemImage: isSaving ? "hourglass" : "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .disabled(isSaving)
                .buttonStyle(.plain)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(saveAlertTitle, isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let msg = saveAlertMessage { Text(msg) }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { .init(url: url) }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
