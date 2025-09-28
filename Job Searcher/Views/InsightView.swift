//
//  InsightView.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/28/25.
//

import SwiftUI

struct InsightView: View {
    let insight: JobInsights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let feedback = insight.feedback, !feedback.isEmpty {
                Text(feedback)
                    .font(.headline)
            }
            
            if !insight.skills.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Skills")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(insight.skills, id: \.self) { skill in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(skill.name)
                                        .font(.subheadline).bold()
                                    Text(skill.proficiencyLevel)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let category = skill.category, !category.isEmpty {
                                        Text(category)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    if let summary = insight.summary, !summary.isEmpty {
                        Text(summary)
                            .font(.footnote)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
