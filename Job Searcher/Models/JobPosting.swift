//
//  PostData.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/13/25.
//

import Foundation

struct JobPosting: Identifiable, Codable, Hashable {
    let id: String                 // unique id from backend
    let title: String
    let company: String?
    let location: String?
    let source: String?            // e.g., "workday", "netflix", "amazon"
    let url: URL?
    let postedAt: Date?
    let description: String?
}
