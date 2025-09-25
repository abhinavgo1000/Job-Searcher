//
//  PostData.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/13/25.
//

import Foundation

struct JobPosting: Identifiable, Codable, Hashable {
    private let _id0: String
    var id: String { _id0 }

    let _id: String?
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
        case source, company, title, location, remote, _id
        case techStack = "tech_stack"
        case compensation, url
        case jobId = "job_id"
        case descriptionSnippet = "description_snippet"
        case id
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        _id = try c.decodeIfPresent(String.self, forKey: ._id)
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
        _id0 = providedId ?? jobId ?? url ?? "\(source)|\(company!)|\(title)|\(location ?? "")"
    }
    
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        
        try c.encode(source, forKey: .source)
        try c.encode(company, forKey: .company)
        try c.encode(title, forKey: .title)
        try c.encode(location, forKey: .location)
        try c.encode(remote, forKey: .remote)
        
        try c.encode(techStack, forKey: .techStack)
        
        if let compensation = compensation {
            try c.encode(compensation, forKey: .compensation)
        }
        
        try c.encode(url, forKey: .url)
        try c.encode(jobId, forKey: .jobId)
        try c.encode(descriptionSnippet, forKey: .descriptionSnippet)
    }

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
