# Platform Scaffold — Setup Notes

This documents exactly what was generated, what was deliberately **not**
hand-fabricated (and why), and the manual steps required before
`flutter pub get` / `flutter build apk --release` will succeed.

---

## What's real and complete

- **`android/`** — full Gradle project (Kotlin support via the
  `org.jetbrains.kotlin.android` plugin, Material 3 via
  `uses-material-design: true` already in `pubspec.yaml` + AndroidX
  enabled), `minSdk 26` / `compileSdk 35` / `targetSdk 34` matching the
  locked platform baseline in `docs/03_System_Architecture.md` §22A,
  core-library-desugaring enabled for `flutter_local_notifications`, the
  exact-alarm/notification permissions RFC-006 depends on, and **real
  launcher icon PNGs** at every mipmap density (not placeholders left
  empty).
- **`web/`** — `index.html` (using Flutter 3.22+'s `flutter_bootstrap.js`
  loader pattern, matching this project's `flutter: ">=3.22.0"`
  constraint), `manifest.json`, and real icon/favicon PNGs.
- **`ios/`** — `Podfile`, `Info.plist` (minimum iOS 15, matching the same
  platform baseline), `AppDelegate.swift`, both storyboards, and a
  **complete, real `AppIcon.appiconset`** (18 PNGs at every required
  iPhone/iPad/App Store size) with a correct `Contents.json`.

All PNGs use LifeOS's actual brand tokens (`#0E0E11` background, `#6E2233`
burgundy) from `lib/theme/tokens/colors.dart` rather than generic
placeholders — they're real, valid images, just a simple monogram rather
than final brand artwork.

---

## What's deliberately NOT generated, and why

### `ios/Runner.xcodeproj/project.pbxproj` and `ios/Runner.xcworkspace`

These are not simple templates — `project.pbxproj` is a UUID-keyed,
internally cross-referenced generated format (every file reference, build
phase, and target has to agree on matching identifiers). Hand-authoring
one that's subtly wrong produces a project that **looks complete but
fails to open in Xcode or fails CI in confusing ways** — worse than
clearly flagging the gap. This is the one piece of the scaffold that
should come from `flutter create .` or Xcode itself, not from hand-typed
text.

**Fix:** in a real Flutter environment, run `flutter create .` from the
repo root once. It detects the existing `ios/` folder is incomplete and
fills in exactly `Runner.xcodeproj` and `Runner.xcworkspace` — it will
not touch `lib/`, `pubspec.yaml`, or any other existing file, and it will
pick up the `Info.plist`/`AppDelegate.swift`/`Assets.xcassets` already
provided here rather than overwriting them with generic ones (verify with
`git diff` after running it, and revert anything unwanted).

### `android/gradlew`, `android/gradlew.bat`, `android/gradle/wrapper/gradle-wrapper.jar`

`gradle-wrapper.jar` is a binary file — it cannot be authored as text.
`gradlew`/`gradlew.bat` are long, precise shell/batch scripts; a
hand-reproduced one with a subtle error is a worse failure mode (silent,
hard-to-diagnose) than a clearly missing one you regenerate correctly.

**Fix:** from the `android/` directory, with a system-installed Gradle
available, run:
```
gradle wrapper --gradle-version 8.7
```
This generates all three files matching the version already pinned in
`android/gradle/wrapper/gradle-wrapper.properties`. Alternatively,
running `flutter create .` (see above) regenerates these too.

### `android/local.properties`

Intentionally not created — it's machine-specific (contains your local
`flutter.sdk`/`sdk.dir` paths) and is correctly gitignored. Flutter
auto-creates/updates it the first time you run any `flutter` command
against this project; no manual step needed beyond that.

### App/bundle identifiers

`android/app/build.gradle`'s `applicationId` and `ios/Runner/Info.plist`'s
bundle identifier are both set to the placeholder `com.lifeos.nova`
(matching the project's codename, "Project NOVA"). **Change this to your
own reverse-domain identifier before any real device install or store
submission** — update it in `android/app/build.gradle`
(`namespace`/`applicationId`) and in Xcode's target settings once the
`.xcodeproj` exists (`PRODUCT_BUNDLE_IDENTIFIER`), and rename the Kotlin
package folder (`android/app/src/main/kotlin/com/lifeos/nova/`) to match
if you change it.

### Release signing (Android)

`android/app/build.gradle`'s `release` build type currently signs with
the **debug key** — this is what makes `flutter build apk --release`
succeed without any extra setup, but it is not suitable for distribution.
Before shipping, create a real keystore and a `key.properties` file (both
already covered by `android/.gitignore`) and wire a `signingConfigs.release`
block — standard Flutter deployment docs cover the exact steps.

---

## Manual steps checklist

1. `flutter create .` from the repo root — fills in `ios/Runner.xcodeproj`
   / `ios/Runner.xcworkspace` only (verify with `git status`/`git diff`
   afterward that nothing under `lib/` changed).
2. `cd android && gradle wrapper --gradle-version 8.7` — generates
   `gradlew`, `gradlew.bat`, `gradle-wrapper.jar`.
3. `flutter pub get`
4. `flutter pub run build_runner build --delete-conflicting-outputs` —
   required before `flutter analyze`/`flutter test` will pass cleanly,
   since `Session`/`Task`'s Isar models (`isar_session_model.dart`,
   `isar_task_model.dart`) reference generated `.g.dart` parts that don't
   exist yet (see `IMPLEMENTATION_REPORT.md`).
5. Change the placeholder application/bundle identifier if you intend to
   publish this.
6. `cd ios && pod install` (macOS + Xcode + CocoaPods required) — only
   needed for iOS builds.
7. `flutter analyze`
8. `flutter test`
9. `flutter build apk --release`

None of steps 1–9 could be executed in the sandbox that generated this
scaffold — no `flutter`/`dart`/`gradle` binaries are installed there and
`pub.dev` is network-blocked, consistent with every prior report in this
build. This document is the honest handoff list, not a claim that these
steps have already been run.
