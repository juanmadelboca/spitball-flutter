# Spitball: Your Flutter Architecture Playground 🚀

Ever asked "What's the best Flutter architecture?" and got the answer, *"It depends"*?

This project is the answer to **what it depends on**.

> **Spitball** is a simple game app built multiple times with different architectural patterns. It's a living laboratory designed to give you a hands-on feel for the trade-offs, benefits, and real-world application of each approach.

Welcome! If you've just come from one of my Medium articles, you're in the right place.

---
## Project Origins 📜

This Flutter project is a modern remake and architectural exploration of the original 'Spitball' game, which was first built for Android in native Java back in 2016. It serves as a great example of how development practices and architectural thinking have evolved.

You can find the original Android project here: [**Spitball for Android**](https://github.com/juanmadelboca/spitball-android).

---

## The Mission 🎯

This repository isn't just about building one app; it's about exploring solutions to a common problem. Our mission is to:

* **Explore Trade-offs:** Practically demonstrate how different architectures handle the same set of problems.
* **Provide a Learning Resource:** Offer a clear, well-documented codebase for junior to semi-senior developers to learn from.
* **Showcase Flexibility:** Create a foundation that can easily be adapted to different state management solutions (`flutter_bloc`, `riverpod`, `provider`) and backends (`Firebase`, etc.).

---

## Our First Stop: Clean Architecture 🧼

The `main` branch is built using a strict implementation of **Clean Architecture**. This pattern excels at creating a clear separation of concerns, making your app:



* ✅ **Framework Independent:** The core business logic is pure Dart and knows nothing about Flutter.
* ✅ **Highly Testable:** Each layer (UI, Business Logic, Data) can be tested in isolation.
* ✅ **Scalable & Maintainable:** Features are self-contained, making them easy to add, change, or remove.

#### At a glance, our structure looks like this:

* `features/<feature_name>/presentation`: The UI Layer (Widgets, Pages, and BLoC).
* `features/<feature_name>/domain`: The Core Logic (Entities, Use Cases, and Repository Contracts).
* `features/<feature_name>/data`: The Implementation Details (Repository Implementations, API/DB Data Sources).

#### Key Tools Used:

* **State Management:** `flutter_bloc`
* **Dependency Injection:** `get_it`
* **Error Handling:** `dartz` (for the `Either` type)
* **Value Equality:** `equatable`

---

## The Journey Ahead 🗺️

This is just the beginning! Future branches will explore other powerful architectures, including:

* **Riverpod & hooks** 
* **Provider-based Architecture**
* ...and more based on community feedback!

---

## How to Use This Repository

1.  **Read the Article:** This repo is best understood alongside the corresponding [Medium Article Series (link to your first article here)].
2.  **Explore the Branches:** Each major architectural pattern will live in its own branch for easy comparison.
3.  **Run the Code:** Clone the repository, run `flutter pub get`, and explore the implementation for yourself!


[![Medium](https://img.shields.io/badge/Medium-12100E?style=flat-square&logo=medium&logoColor=white)](https://medium.com/@juanmadelboca)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/juanmadelboca/)
[![Google Play](https://img.shields.io/badge/Google_Play-414141?style=flat-square&logo=googleplay&logoColor=white)](https://play.google.com/store/apps/dev?id=5382697591220306267)
