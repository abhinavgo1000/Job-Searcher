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

                NavigationStack { SavedJobsView() }
                    .tabItem {
                        Label("Saved", systemImage: "tray")
                    }
            }
        }
    }
}
