# HAA Convention 2026 — Android App

**The Android companion app for the Havyaka Association of the Americas (HAA) 21st Biennial Convention.**

July 3–5, 2026 · Rosary College Prep · Aurora, Illinois

Built with **Flutter** for **Android** (with shared Dart code that can also target iOS, web, and desktop).

This repository is the **Android port** of the official convention mobile app. Feature parity and convention content are based on the native iOS app in [sohamkaje/havyaka-app-iOS](https://github.com/sohamkaje/havyaka-app-iOS).

---

## Relationship to the iOS App

The iOS repository ([havyaka-app-iOS](https://github.com/sohamkaje/havyaka-app-iOS)) is the original **SwiftUI** convention app. This project replicates the same attendee experience on Android using **Flutter**:

| Area | iOS (`havyaka-app-iOS`) | Android (this repo) |
|------|-------------------------|---------------------|
| UI framework | SwiftUI | Flutter / Material |
| Maps | Apple Maps | OpenStreetMap (`flutter_map`) |
| Auth & check-in | `RegistrationAPI` → `auth.php` | Same backend via `registration_api.dart` |
| Photo gallery | `PhotosAPI` → `photos.php` + R2 | Same backend via `photos_api.dart` |
| Offline schedule, map, info | Bundled in `ConventionModels.swift` | Bundled in `convention_models.dart` + `schedule_data_2026.dart` |
| Design | HAA colors, Georgia serif | HAA design system (`design_system.dart`, Google Fonts) |

When convention data or flows change in the iOS app, update the corresponding Dart models, schedule data, and views here to keep both apps aligned.

---

## What It Is

This is the convention companion app attendees use on their phones during HAA 2026. It brings the full program, venue map, convention info, shared photo gallery, and account tools into one place — designed for use on the convention floor, in hotels, and throughout the weekend.

Most of the app works **offline** (schedule, map, convention info). **Account sign-in, check-in, and the photo gallery** require an internet connection and talk to the HAA backend on Bluehost (same APIs as the iOS app).

---

## How It Works

### App structure (5 tabs)

| Tab | What it does |
|-----|----------------|
| **Home** | Countdown to convention start (then “Convention has started!”), quick-access shortcuts, star attractions, and a **Log in here** button when signed out |
| **Schedule** | Full 4-day program (Jul 2–5) with expandable event cards and detail sheets |
| **Map** | OpenStreetMap with venue, hotel, and food locations; filters, directions, Rosary campus venue guide, and detail sheets |
| **Photos** | Shared attendee gallery — **login required** to view and upload |
| **More** | Two sections: **Info** (venue, committees, FAQ, sponsors, about HAA) and **Account** (sign up, log in, profile, check-in) |

The Home quick-access cards and **Log in here** button navigate directly to the right tab or section.

### Account & check-in

Attendees who registered for the convention can link the app to their registration:

1. **Sign Up** — enter the registrant email; a 5-digit login code is emailed via the backend
2. **Log In** — enter email + 5-digit code; profile is saved locally on the device
3. **Check In** — once logged in, use the check-in flow with QR code at the **Check-in Desk** at Rosary College Prep

Auth is handled by `auth.php` against the existing MySQL registration table (same as iOS).

### Photo gallery

The shared gallery uses `photos.php` + **Cloudflare R2** (see the iOS repo’s `api/migrations/PHOTOS_R2_SETUP.md`):

- **List** — loads photo metadata from MySQL on Bluehost
- **Upload** — compressed images uploaded via the API to R2
- **Limits** — per-user photo/video limits enforced by the backend

If the API is unreachable, the Photos tab shows an offline banner.

### Offline behavior

A network monitor shows a banner on **Account** and **Photos** when there is no service. Home, Schedule, Map, and the Info section of More work without a connection using bundled convention data.

---

## Project Structure

```
havyaka-app-android/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── theme/
│   │   └── design_system.dart    # Colors, typography, spacing
│   ├── models/
│   │   └── convention_models.dart
│   ├── data/
│   │   └── schedule_data_2026.dart
│   ├── services/
│   │   ├── auth_view_model.dart
│   │   ├── registration_api.dart # auth.php client
│   │   ├── photos_api.dart       # photos.php client
│   │   ├── photo_image_processor.dart
│   │   └── network_monitor.dart
│   ├── views/
│   │   ├── home_view.dart
│   │   ├── schedule_view.dart
│   │   ├── map_view.dart
│   │   ├── photos_view.dart
│   │   ├── info_view.dart
│   │   └── account_view.dart
│   └── widgets/
│       └── shared_components.dart
├── assets/images/
│   ├── app_logo.png              # App icon + in-app branding
│   └── rosary_campus_map.png     # Rosary College Prep venue guide
└── android/                      # Android host project
```

Convention-specific content (schedule days, map pins, venue areas, FAQ text, etc.) lives under `lib/models/` and `lib/data/` so it can be updated for future conventions without restructuring the app.

---

## Backend

The app calls the same live APIs as the iOS app:

- `https://havyak.org/api/auth.php` — registration login and check-in
- `https://havyak.org/api/photos.php` — photo gallery (files on Cloudflare R2)

PHP backend source, migrations, and deployment notes live in the [iOS repository](https://github.com/sohamkaje/havyaka-app-iOS) under `api/`.

---

## Open & Run (developers)

**Requirements:** Flutter **3.44+** (Dart **3.12+**), Android SDK, and a device or emulator.

```bash
cd havyaka-app-android-main   # project root (where pubspec.yaml lives)
flutter pub get
flutter run
```

Build a release APK:

```bash
flutter build apk --release
```

### Google Play Store

Application ID: **`org.havyak.haa_convention`**

Full deployment steps (Play Console account, signing keystore, AAB build, store listing, upload): see **[docs/google-play-deployment.md](docs/google-play-deployment.md)**.

Quick release build:

```bash
# 1. Create android/key.properties (see android/key.properties.example)
# 2. Run android/create-upload-keystore.ps1 if you don't have a keystore yet
flutter build appbundle --release
```

**Android notes:**

- Enable **Developer Mode** on Windows if plugin builds fail due to symlink support.
- NDK **28.2.13676358** is required (Flutter 3.44 default); install via Android SDK Manager if Gradle reports a missing NDK.

Regenerate launcher icons after changing `assets/images/app_logo.png`:

```bash
dart run flutter_launcher_icons
```

---

## Design

| Token | Role |
|-------|------|
| `HAAColors.charcoal` | Nav bars, dark headers |
| `HAAColors.orange` | Primary actions |
| `HAAColors.gold` | Accents and highlights |
| `HAAColors.cream` | Page backgrounds |
| Serif (Google Fonts) | Display headings and Kannada text |
| Sans | UI body copy |

---

## Related Repositories

- **iOS (source of features & backend):** [github.com/sohamkaje/havyaka-app-iOS](https://github.com/sohamkaje/havyaka-app-iOS)
- **Android (this repo):** [github.com/sohamkaje/havyaka-app-android](https://github.com/sohamkaje/havyaka-app-android)

---

*Official HAA Convention 2026 mobile app · Havyaka Association of the Americas*
