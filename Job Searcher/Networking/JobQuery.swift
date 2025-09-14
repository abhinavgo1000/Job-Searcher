//
//  NetworkManager.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/13/25.
//

import Foundation

struct JobQuery: Equatable {
    var q: String = ""
    var city: String = ""
    var includeNetflix: Bool = true
    var workday: String = ""   // e.g. "pwc.wd3.myworkdayjobs.com:Global_Experienced_Careers:pwc"
    var strict: Bool = true
    var page: Int = 1
    var pageSize: Int = 20

    func asQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: "q", value: q.isEmpty ? nil : q),
            .init(name: "city", value: city.isEmpty ? nil : city),
            .init(name: "include_netflix", value: String(includeNetflix)),
            .init(name: "strict", value: String(strict)),
        ]
        if !workday.isEmpty { items.append(.init(name: "workday", value: workday)) }
        // If the backend supports page/page_size:
        items.append(.init(name: "page", value: String(page)))
        items.append(.init(name: "page_size", value: String(pageSize)))
        return items
    }
}
