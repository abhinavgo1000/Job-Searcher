//
//  Job_SearcherApp.swift
//  Job Searcher
//
//  Created by Abhinav Goel on 9/11/25.
//

import SwiftUI

@main
struct Job_SearcherApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack { ContentView() }
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                
                NavigationStack { JobInsightsView() }
                    .tabItem {
                        Label("Research", systemImage: "rectangle.and.text.magnifyingglass")
                    }

                NavigationStack { SavedJobsView() }
                    .tabItem {
                        Label("Saved Jobs", systemImage: "tray")
                    }
                
                NavigationStack { SavedInsightsView() }
                    .tabItem {
                        Label("Saved Insights", systemImage: "tray.full")
                    }
            }
        }
    }
}
