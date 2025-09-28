//
//  InsightsQuery.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/27/25.
//

import Foundation

struct InsightsQuery: Equatable {
    var position: String = ""
    var companies: [String] = []
    var yearsExperience: Int = 0
    var remote: Bool = false
    var page: Int = 1
    var pageSize: Int = 20
    
    func asQueryItems() -> [URLQueryItem] {
        let companiesValue: String? = {
            let normalized = companies
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { $0.lowercased() }
            return normalized.isEmpty ? nil : normalized.joined(separator: ",")
        }()
        let items: [URLQueryItem] = [
            .init(name: "position", value: position.isEmpty ? nil : position),
            .init(name: "companies", value: companiesValue),
            .init(name: "years_experience", value: String(yearsExperience)),
            .init(name: "remote", value: String(remote)),
            .init(name: "page", value: String(page)),
            .init(name: "page_size", value: String(pageSize))
        ]
        return items
    }
}

