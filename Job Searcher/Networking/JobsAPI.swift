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
    
    func saveJob(job: JobPosting) async throws -> JobPosting? {
        let url = baseURL.appendingPathComponent("save-job")

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let body = try encoder.encode(job)
        req.httpBody = body

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.init(rawValue: http.statusCode))
        }

        // Some backends return an empty body on success.
        if data.isEmpty { return nil }

        do {
            return try Self.decoder.decode(JobPosting.self, from: data)
        } catch {
            if let s = String(data: data, encoding: .utf8) {
                print("SaveJob decode failed, raw body:\n\(s)")
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
    
    func fetchSavedJobs() async throws -> [JobPosting] {
        let url = baseURL.appendingPathComponent("saved-jobs")

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.init(rawValue: http.statusCode))
        }

        // Some backends may return an empty body when there are no saved jobs
        if data.isEmpty { return [] }

        do {
            return try Self.decoder.decode([JobPosting].self, from: data)
        } catch {
            if let s = String(data: data, encoding: .utf8) {
                print("fetchSavedJobs decode failed, raw body:\n\(s)")
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

    /// Remove a saved job by its identifier.
    /// Uses RESTful DELETE at `delete-jobs/{id}`. Returns on success; throws on failure.
    func unsaveJob(id: String) async throws {
        let url = baseURL
            .appendingPathComponent("delete-jobs")
            .appendingPathComponent(id)

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.init(rawValue: http.statusCode))
        }
        // Many backends return an empty body for DELETE on success; nothing to decode here.
    }
}
