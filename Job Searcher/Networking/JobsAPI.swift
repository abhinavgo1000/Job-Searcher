//
//  JobsAPI.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/14/25.
//

import Foundation

struct JobsAPI {
    let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        // ISO8601 dates like "2025-09-12T10:30:00Z"
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func searchJobs(query: JobQuery, cancellationToken: CancellationToken? = nil) async throws -> [JobPosting] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("/jobs"), resolvingAgainstBaseURL: false)!
        comps.queryItems = query.asQueryItems()

        guard let url = comps.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await session.data(for: req, delegate: cancellationToken)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try Self.decoder.decode([JobPosting].self, from: data)
    }
}

/// Simple cancellation support that integrates with URLSessionTaskDelegate
final class CancellationToken: NSObject, URLSessionTaskDelegate {
    private(set) var task: URLSessionTask?
    private func urlSession(_ session: URLSession, task: URLSessionTask, didCreate task2: URLSessionTask) {
        self.task = task2
    }
    func cancel() { task?.cancel() }
}
