//
//  PostData.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/13/25.
//

import Foundation

struct JobPosting: Identifiable, Decodable, Hashable {
    private let _id: String
    var id: String { _id }

    let source: String
    let company: String?
    let title: String
    let location: String?
    let remote: Bool?
    let techStack: [String]            // default [] if missing/null
    let compensation: Compensation?    // null-able on server
    let url: String?                   // decode as String; build URL later
    let jobId: String?
    let descriptionSnippet: String?

    enum CodingKeys: String, CodingKey {
        case source, company, title, location, remote
        case techStack = "tech_stack"
        case compensation, url
        case jobId = "job_id"
        case descriptionSnippet = "description_snippet"
        case id
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        source = try c.decode(String.self, forKey: .source)
        company = try c.decode(String.self, forKey: .company)
        title   = try c.decode(String.self, forKey: .title)
        location = try c.decodeIfPresent(String.self, forKey: .location)
        remote   = try c.decodeIfPresent(Bool.self, forKey: .remote)

        // ✅ tolerant decode — defaults to []
        techStack = try c.decodeIfPresent([String].self, forKey: .techStack) ?? []

        compensation = try c.decodeIfPresent(Compensation.self, forKey: .compensation)
        url   = try c.decodeIfPresent(String.self, forKey: .url)
        jobId = try c.decodeIfPresent(String.self, forKey: .jobId)
        descriptionSnippet = try c.decodeIfPresent(String.self, forKey: .descriptionSnippet)

        let providedId = try c.decodeIfPresent(String.self, forKey: .id)
        _id = providedId ?? jobId ?? url ?? "\(source)|\(company!)|\(title)|\(location ?? "")"
    }

    static func == (lhs: JobPosting, rhs: JobPosting) -> Bool { lhs._id == rhs._id }
    func hash(into hasher: inout Hasher) { hasher.combine(_id) }
}

struct Compensation: Decodable, Equatable, Hashable {
    let currency: String?
    let min: Float?
    let max: Float?
    let period: String?
    let notes: String?
}
