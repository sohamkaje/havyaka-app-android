# Google Play Store — Deployment Handoff

Use this guide after the Android release configuration in the repo is complete.

## 1. Google Play Developer account

1. Sign up at [Google Play Console](https://play.google.com/console/signup)
2. Pay the **$25** one-time registration fee
3. Complete identity verification (often 24–48 hours)
4. Choose **Personal** (faster) or **Organization** (official HAA publisher; may require D-U-N-S)

## 2. Release signing (one-time, on your machine)

```powershell
cd havyaka-app-android-main
.\android\create-upload-keystore.ps1
```

Then create `android/key.properties` from the example:

```powershell
Copy-Item android\key.properties.example android\key.properties
# Edit key.properties with your passwords and keystore path
```

`key.properties` is gitignored — never commit it.

## 3. Build the App Bundle

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

Upload this file to Play Console:

`build/app/outputs/bundle/release/app-release.aab`

Optional device test:

```powershell
flutter build apk --release
flutter install --release
```

## 4. Store listing copy

### App name
**HAA Convention**

### Short description (80 chars max)
Official companion app for the HAA 21st Biennial Convention in Aurora, IL.

### Full description
The official mobile companion for the Havyaka Association of the Americas (HAA) 21st Biennial Convention — July 3–5, 2026 at Rosary College Prep, Aurora, Illinois.

**Features:**
- Full 4-day convention schedule with event details and venues
- Interactive map with hotels, dining, and Rosary campus venue guide
- Convention info, committees, FAQ, and sponsors
- Account sign-in linked to your convention registration
- On-site check-in with QR code
- Shared photo gallery for attendee memories

Most content works offline. Sign-in, check-in, and photo upload require internet.

Built for attendees of HAA Convention 2026. Android port of the official iOS convention app.

### Release notes (first release)
Initial release of the HAA Convention 2026 Android app.

## 5. Required Play Console assets

| Asset | Spec |
|-------|------|
| App icon | 512×512 PNG — use `assets/images/app_logo.png` |
| Feature graphic | 1024×500 PNG |
| Phone screenshots | Minimum 2 (e.g. Home, Schedule, Map) |
| Privacy policy URL | **Required** — must cover email login and photo uploads |

### Privacy policy must mention
- Email used for convention registration login (`havyak.org/api/auth.php`)
- Photos uploaded to the shared gallery (`havyak.org/api/photos.php`, Cloudflare R2)
- Profile data stored locally on device (`shared_preferences`)

Host on `haaconvention.org` or `havyak.org`.

### Data safety (typical answers)
- **Data collected:** Email address; photos/videos (user-provided)
- **Data shared:** Photos uploaded to convention gallery backend
- **Encryption in transit:** Yes (HTTPS)
- **Users can request deletion:** Contact secretary@havyak.org

### Content rating
Complete the IARC questionnaire. No violence, gambling, or user-generated public social feed beyond convention photo gallery.

### Target audience
General audience / 18+ (not designed for children).

## 6. Upload and release

1. Play Console → **Create app** → name **HAA Convention**, default language English, Free app
2. Complete all **Policy** and **Store listing** sections until no errors remain
3. **Testing → Internal testing** → Create release → Upload `app-release.aab`
4. Add your Gmail as an internal tester → install from Play link → verify login, map, schedule, photos
5. **Production** → Create release → same AAB → Submit for review
6. On first upload, accept **Play App Signing** (recommended)

### Application ID
`org.havyak.haa_convention` (must match the uploaded bundle)

## 7. Future updates

1. Bump `version` in `pubspec.yaml` (e.g. `1.0.1+2` — versionCode must increase)
2. `flutter build appbundle --release`
3. Upload new AAB in Play Console

---

*Related: [iOS app](https://github.com/sohamkaje/havyaka-app-iOS) · [Android repo](https://github.com/sohamkaje/havyaka-app-android)*
