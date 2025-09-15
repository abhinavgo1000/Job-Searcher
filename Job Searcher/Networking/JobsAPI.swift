//
//  JobsAPI.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/14/25.
//

import Foundation

struct JobsAPI {
    let baseURL: URL
    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.waitsForConnectivity = true
        return URLSession(configuration: cfg)
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase   // important
        return d
    }()

    func searchJobs(query: JobQuery) async throws -> [JobPosting] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("/jobs"), resolvingAgainstBaseURL: false)!
        comps.queryItems = query.asQueryItems()
        let url = comps.url!

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.init(rawValue: http.statusCode))
        }

        do {
            return try Self.decoder.decode([JobPosting].self, from: data)
        } catch {
            // SUPER USEFUL while debugging
            if let s = String(data: data, encoding: .utf8) {
                print("Decoding failed, raw body:\n\(s)")
            }
            if let decErr = error as? DecodingError {
                switch decErr {
                case .keyNotFound(let k, let ctx): print("KeyNotFound:", k, ctx.debugDescription)
                case .typeMismatch(let t, let ctx): print("TypeMismatch:", t, ctx.debugDescription)
                case .valueNotFound(let v, let ctx): print("ValueNotFound:", v, ctx.debugDescription)
                case .dataCorrupted(let ctx): print("DataCorrupted:", ctx.debugDescription)
                @unknown default: print("Unknown decoding error")
                }
            } else {
                print("Non-decoding error:", error.localizedDescription)
            }
            throw error
        }
    }
}
