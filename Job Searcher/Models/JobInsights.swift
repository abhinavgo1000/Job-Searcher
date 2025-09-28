//
//  JobInsights.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/20/25.
//

import Foundation

struct JobInsights: Identifiable, Codable, Hashable {
    let _id: String?
    var id: String? { _id }
    
    let summary: String?
    let skills: [SkillDetail]
    let feedback: String?
    
    enum CodingKeys: String, CodingKey {
        case id, summary, skills, feedback
    }
    
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try c.decodeIfPresent(String.self, forKey: .id)
        summary = try c.decode(String.self, forKey: .summary)
        skills = try c.decode([SkillDetail].self, forKey: .skills)
        feedback = try c.decodeIfPresent(String.self, forKey: .feedback)
    }
    
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        
        try c.encode(summary, forKey: .summary)
        try c.encode(skills, forKey: .skills)
        if let feedback = feedback {
            try c.encode(feedback, forKey: .feedback)
        }
    }
}

struct SkillDetail: Codable, Equatable, Hashable {
    let name: String
    let description: String
    let proficiencyLevel: String
    let category: String?
}
