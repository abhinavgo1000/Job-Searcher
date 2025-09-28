# 📱 Job Searcher iOS App

* A SwiftUI iOS client for the Job Searcher AI backend. This app lets you query multiple job sources (Workday, Netflix, Amazon India, etc.) through your backend API and view the results in a clean, mobile-friendly interface.
* Also used to query and display job related insights based on position, companies, years of experience and whether remote roles or not.

---

## 🚀 Features

* 🔎 **Search by role and city** (e.g., `Full Stack`, `Bengaluru`)
* 🎛 **Filters**

  * Workday filters (e.g., `pwc.wd3.myworkdayjobs.com:Global_Experienced_Careers:pwc`)
  * Toggle `Include Netflix`
  * Toggle `Strict`
* 📄 **Job listings** with title, company, location, and source
* 📖 **Job detail view** with description and direct link to the original posting
* 🌐 **Opens job links** in Safari inside the app
* 🔄 Pull-to-refresh & load-more pagination

---

## 🛠 Tech Stack

* **SwiftUI** for UI
* **Async/Await (Swift Concurrency)** for networking
* **URLSession** for API requests
* **MVVM architecture** (View → ViewModel → API Client)
* **Codable models** for parsing JSON from backend

---

## 📸 Screenshots

<p align="center">
  <img src="./Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202025-09-28%20at%2015.17.13.png" width="300" alt="Landing Page Screenshot">
</p>
<p align="center">
  <img src="./Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202025-09-28%20at%2015.17.21.png" width="300" alt="Job Detail Screenshot">
</p>
<p align="center">
  <img src="./Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202025-09-28%20at%2015.17.31.png" width="300" alt="Insight Search Screenshot">
</p>
<p align="center">
  <img src="./Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202025-09-28%20at%2015.17.43.png" width="300" alt="Saved Jobs Screenshot">
</p>
<p align="center">
  <img src="./Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202025-09-28%20at%2015.17.54.png" width="300" alt="Saved Insights Screenshot">
</p>

---

## 📂 Project Structure

```
JobSearch/
├── Models/
│   ├── JobPosting.swift
|   └── JobInsights.swift
├── Networking/
│   ├── JobQuery.swift
│   ├── JobsAPI.swift
|   ├── InsightsQuery.swift
|   └── InsightsAPI.swift
├── ViewModels/
│   ├── JobsViewModel.swift
|   └── InsightsViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── InsightView.swift
│   ├── JobDetailsView.swift
│   ├── JobInsightsView.swift
│   ├── SavedInsightsView.swift
│   └── SavedJobsView.swift
├── Support/
│   └── AppConfig.swift
└── JobSearchApp.swift
```

---

## ⚙️ Setup

1. Clone the repo:

   ```bash
   git clone https://github.com/abhinavgo1000/Job-Searcher.git
   cd Job-Searcher
   ```
2. Open `Job Searcher.xcodeproj` in Xcode.
3. Add your backend base URL in **Info.plist**:

   ```xml
   <key>JOB_API_BASE_URL</key>
   <string>http://127.0.0.1:5057</string>
   ```

   * Use `http://127.0.0.1:5057` for Simulator
   * Use your LAN IP (e.g. `http://192.168.1.10:5057`) for physical device
4. Run the Flask backend locally:

   ```bash
   flask run --host=0.0.0.0 --port=5057
   ```
5. Build & run the app on Simulator or device.

---

## 🧩 Example JSON Response

Make sure your backend returns job postings in this format (fields may vary):

### Jobs

```json
[
  {
    "job_id": "abc123",
    "title": "Full Stack Engineer",
    "company": "PwC",
    "location": "Bengaluru",
    "source": "workday",
    "remote": false,
    "tech_stack": ["Swift", "Angular", "AWS"],
    "compensation": {
      "currency": "INR",
      "min": 2000000,
      "max": 3000000,
      "period": "year",
      "notes": "Depends on experience"
    },
    "url": "https://example.com/job/abc123",
    "description_snippet": "We are hiring a Full Stack Engineer..."
  }
]
```

### Insights

```json
[
  {
   "summary": "Strong backend and cloud skills required.",
   "skills": [
     {
       "name": "Python",
       "description": "Used for backend development.",
       "proficiency_level": "Expert",
       "category": "Backend"
     },
     {
       "name": "AWS",
       "description": "Cloud deployment and management.",
       "proficiency_level": "Intermediate",
       "category": "Cloud"
     }
   ],
   "feedback": "Ensure hands-on experience with cloud platforms."
 }
]
```

---

## 📌 Roadmap

* [ ] Offline caching with SwiftData
* [ ] Bookmarks / Favorites
* [ ] Push notifications for new jobs
* [ ] Dark mode support
* [ ] Multi-language support

---

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.

