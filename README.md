# Health Tick – Journey

A recreation of Health Tick's **Journey** screen and **daily lessons** in Flutter. The data comes from a small **dummy API inside the app** with hard-coded content, so there is no server to run.

- Two levels, **Beginner** and **Insider**. The dummy API decides how many circles each has.
- Only the **first circle** starts unlocked. **Finishing every lesson in a circle unlocks the next one**, and the Journey page updates in real time.
- Tap a circle to see that day's lessons, then tap a lesson to open it.
- Lessons have two page types: **text** pages and **question** pages.

> For a full walkthrough of every part (including how the zig-zag road is calculated and drawn), see **[PROJECT_GUIDE.md](PROJECT_GUIDE.md)**.

## Run it

```bash
flutter pub get
flutter run        # Android, iOS, web or macOS
flutter test       # all tests
```

## Where the data is

| File | What it holds |
|---|---|
| `lib/data/dummy_api/hardcoded/journey_config_data.dart` | Levels, circles per level, circles unlocked at the start |
| `lib/data/dummy_api/hardcoded/lesson_content_data.dart` | Each circle's lessons and each lesson's pages (only Beginner days 1–2 have lessons) |

How to add levels, circles and lessons is explained in [PROJECT_GUIDE.md, section 11](PROJECT_GUIDE.md#11-adding-levels-and-tasks).

## Architecture: layer-first clean architecture

```
lib/
├── main.dart          entry point, global error handlers
├── app/               MaterialApp shell
├── core/              errors (Failure / Result / guard), ApiClient interface, theme, utils
├── di/                providers.dart: Riverpod providers, the only place that names concrete classes
├── domain/            entities, repository interfaces, use cases (pure Dart)
├── data/              data sources, JSON models, repository implementations, dummy_api/
└── presentation/      Riverpod notifiers, pages, widgets
```

- **Dependency rule:** `presentation → domain ← data`. `domain/` imports nothing from the other layers.
- **State management:** Riverpod.
  - `journeyProvider` is shared app-wide by the Today and Journey screens.
  - `lessonPlayerProvider(lessonId)` lives only while a lesson is open.
- **Real time:** the dummy server signals every change, and the app reloads the journey.
- **Errors are values:**
  - Repositories return `Result` (`Ok` or `Err`) and never throw.
  - `guard()` turns exceptions into typed `Failure`s.
  - The UI picks the message, icon and retry button for each failure.
