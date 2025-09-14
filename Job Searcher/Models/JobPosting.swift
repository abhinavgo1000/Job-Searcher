//
//  PostData.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/13/25.
//

import Foundation

struct JobPosting: Codable, Identifiable, Hashable {
    // Store a stable id once (decoded or generated), don't compute new UUIDs each access
    private let _id: String
    var id: String { _id }

    var source: String?
    var company: String?
    var title: String
    var location: String?
    let remote: Bool?
    let tech_stack: [String]
    let compensation: Compensation
    let url: String?
    let job_id: String?
    let description_snippet: String?

    enum CodingKeys: String, CodingKey {
        case source, company, title, location, remote, tech_stack, compensation, url, job_id, description_snippet
    }

    // Manual decode to initialize the stable _id once
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.source = try c.decode(String.self, forKey: .source)
        self.company = try c.decode(String.self, forKey: .company)
        self.title = try c.decode(String.self, forKey: .title)
        self.location = try c.decodeIfPresent(String.self, forKey: .location)
        self.remote = try c.decodeIfPresent(Bool.self, forKey: .remote)
        self.tech_stack = try c.decode([String].self, forKey: .tech_stack)
        self.compensation = try c.decode(Compensation.self, forKey: .compensation)
        self.url = try c.decodeIfPresent(String.self, forKey: .url)
        self.job_id = try c.decodeIfPresent(String.self, forKey: .job_id)
        self.description_snippet = try c.decodeIfPresent(String.self, forKey: .description_snippet)

        // prefer backend id; otherwise derive something stable-ish; else fallback UUID (but fixed for this instance)
        self._id = job_id
            ?? url
            ?? "\(source!)|\(company!)|\(title)|\(location ?? "")"
    }

    // Convenience init for tests/manual creation
    init(
        source: String?,
        company: String?,
        title: String,
        location: String? = nil,
        remote: Bool? = nil,
        tech_stack: [String] = [],
        compensation: Compensation,
        url: String? = nil,
        job_id: String? = nil,
        description_snippet: String? = nil
    ) {
        self.source = source
        self.company = company
        self.title = title
        self.location = location
        self.remote = remote
        self.tech_stack = tech_stack
        self.compensation = compensation
        self.url = url
        self.job_id = job_id
        self.description_snippet = description_snippet
        self._id = job_id
            ?? url
            ?? "\(source!)|\(company!)|\(title)|\(location ?? "")"
    }

    // Hash/Equality only on the stable id
    static func == (lhs: JobPosting, rhs: JobPosting) -> Bool { lhs._id == rhs._id }
    func hash(into hasher: inout Hasher) { hasher.combine(_id) }
}

struct Compensation: Codable, Equatable, Hashable {
    let currency: String?
    let min: Float?
    let max: Float?
    let period: String?
    let notes: String?
}

