# 📱 iOS Gallery Application

This project is a **basic gallery application** developed as part of an iOS technical assessment. It demonstrates clean architecture, modern Swift practices, and offline data handling.

---

## 🚀 Features

* 🔐 Google Login
* 🖼️ Image Gallery with Pagination
* 🌐 Fetch images from API (with fallback support)
* 💾 Offline Support using local database
* 👤 Profile Screen with Logout
* 📶 Access images without internet after initial load

---

## 🧱 Architecture

The project follows **MVVM (Model-View-ViewModel)** architecture with proper separation of concerns.

```
Core
 ├── Network
 ├── Storage
 ├── DI

Features
 ├── Auth
 ├── Gallery
 ├── Profile

Shared
 ├── Components
 ├── Theme
```

---

## 🛠️ Tech Stack

* **Language:** Swift
* **UI Framework:** SwiftUI
* **Architecture:** MVVM
* **Networking:** URLSession (async/await)
* **Persistence:** Realm
* **Authentication:** Google Sign-In

---

## 🌐 Data Handling

* Images are fetched from an online API
* Static fallback data is used if API is unavailable
* All images are stored locally in database
* Enables full offline access after initial load

---

## 💾 Offline Support

* Data is persisted using Realm
* When offline:

  * Images are loaded from local database
* Ensures smooth and uninterrupted experience

---

## 🔄 Pagination

* Implemented for efficient loading
* Loads images in chunks
* Optimized for performance and smooth scrolling

---

## 🔑 Setup Instructions

1. Clone the repository
2. Open project in Xcode
3. Add your API key (if required) in:

   ```
   APIEndpoint.swift
   ```
4. Configure Google Sign-In (URL Schemes & Console)
5. Run the project

---

## ✅ Requirements Covered

✔ Google Login
✔ Image list with pagination
✔ Offline persistence using database
✔ Profile screen with logout
✔ MVVM architecture
✔ Clean and scalable code structure

---

## 👨‍💻 Author

**Pushti Delvadiya**

---

## 📌 Summary

This project focuses on:

* Clean architecture
* Offline-first approach
* Scalable and maintainable code
* Real-world app behavior

---

