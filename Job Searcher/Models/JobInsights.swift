//
//  JobInsights.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/20/25.
//

import Foundation

struct JobInsights: Decodable {
    let total: Int
    let data: [JobPosting]
}
