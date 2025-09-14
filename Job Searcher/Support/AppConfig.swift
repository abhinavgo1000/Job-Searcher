//
//  AppConfig.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/14/25.
//

import Foundation

enum AppConfig {
    static var baseURL: URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "JOB_API_BASE_URL") as? String,
            let url = URL(string: raw)
        else {
            fatalError("Missing or invalid JOB_API_BASE_URL in Info.plist")
        }
        return url
    }
}
