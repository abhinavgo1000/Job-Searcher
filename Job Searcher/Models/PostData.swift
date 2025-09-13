//
//  PostData.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/13/25.
//

import Foundation

struct Results: Decodable {
    let hits: [JobPosting]
}

struct JobPosting: Decodable, Identifiable {
    let id: String?
    var source: String
    var company: String
    var title: String
    var location: String?
    let remote: Bool?
    let tech_stack: [String]
    let compensation: Compensation
    let url: String?
    let job_id: String?
    let description_snippet: String?
}

struct Compensation: Decodable {
    let currency: String?
    let min: Float?
    let max: Float?
    let period: String?
    let notes: String?
}
