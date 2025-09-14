# 📱 Job Search iOS App

A SwiftUI iOS client for the Job Searcher AI backend. This app lets you query multiple job sources (Workday, Netflix, Amazon India, etc.) through your backend API and view the results in a clean, mobile-friendly interface.

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

## 📸 Screenshot

<p align="center">
  <img src="./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-09-14%20at%2016.52.39.png" width="300" alt="App Screenshot">
</p>

---

## 📂 Project Structure

```
JobSearch/
├── Models/
│   └── JobPosting.swift
├── Networking/
│   ├── JobQuery.swift
│   └── JobsAPI.swift
├── ViewModels/
│   └── JobsViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── JobRow.swift
│   └── JobDetailView.swift
├── Support/
│   └── AppConfig.swift
└── JobSearchApp.swift
```

---

## ⚙️ Setup

1. Clone the repo:

   ```bash
   git clone https://github.com/yourusername/jobsearch-ios.git
   cd jobsearch-ios
   ```
2. Open `JobSearch.xcodeproj` in Xcode.
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

