# Pray Then Play (PTP) — The Gaming Salah Companion

<div align="center">

![Pray Then Play Banner](assets/images/banner_github_hero.png)

### *Salah first. Gaming second. Stay on time. Play with peace of mind.*

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-Native%20Widgets-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Windows](https://img.shields.io/badge/Windows-Desktop%20%7C%20Tray-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com)
[![Web](https://img.shields.io/badge/Web-Live%20Companion-00E676?style=for-the-badge&logo=googlechrome&logoColor=black)](https://tryomar.github.io/pray-then-play-website/app/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

[Features](#key-capabilities) • [Architecture](#technical-architecture) • [Getting Started](#getting-started) • [Widgets](#native-android-widgets) • [Themes](#11-theme-matrix) • [Localization](#internationalization--rtl-support) • [Ecosystem](#the-pray-then-play-ecosystem)

</div>

---

## Executive Summary

**Pray Then Play** (*PTP*) is an open-source gaming companion and spiritual habit tracker engineered specifically for Muslim gamers. It bridges the gap between competitive gaming and Islamic prayer commitments (*Salah*).

By cross-referencing high-precision astronomical prayer calculations against match durations, queue times, overtime variances, and custom safety buffers, **Pray Then Play** provides real-time, deterministic queue verdicts. Muslim gamers never have to abandon teammates, incur AFK penalties, or delay their prayers.

> [!IMPORTANT]
> **Core Principle**: Pray Then Play operates **100% offline** with zero telemetry, zero analytics, and zero account requirements. Location data is processed ephemerally on-device solely to compute solar prayer angles.

---

## Table of Contents

- [The Problem and Solution](#the-problem-and-solution)
- [Key Capabilities](#key-capabilities)
  - [Smart Queue Decision Engine](#smart-queue-decision-engine)
  - [High-Precision Astronomical Prayer Engine](#high-precision-astronomical-prayer-engine)
  - [5-Prayer Consistency Heatmap](#5-prayer-consistency-heatmap)
  - [Preconfigured Game Catalog and Custom Creator](#preconfigured-game-catalog-and-custom-creator)
  - [11-Theme Matrix and Lighting Engine](#11-theme-matrix-and-lighting-engine)
  - [Internationalization and RTL Support](#internationalization-and-rtl-support)
  - [Native Android Widgets](#native-android-widgets)
  - [Desktop Integration](#desktop-integration)
  - [Privacy and Offline Architecture](#privacy-and-offline-architecture)
- [Technical Architecture](#technical-architecture)
- [Project Directory Structure](#project-directory-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Local Development](#local-development)
  - [Building Production Binaries](#building-production-binaries)
- [The Pray Then Play Ecosystem](#the-pray-then-play-ecosystem)
- [Contributing](#contributing)
- [License](#license)

---

## The Problem and Solution

| Challenge | Solution |
| :--- | :--- |
| **Ranked Match Overlap**: Starting a 40-minute match with only 30 minutes before Adhan leads to mid-game AFKs, lost rating, or delayed prayers. | **Deterministic Math**: Calculates uninterrupted gaming windows minus customizable safety buffers (5m, 10m, 15m), accounting for maximum match durations and overtime. |
| **Mid-Game Anxiety**: Constantly checking the clock disrupts gaming focus and prayer mindfulness (*Khushu*). | **Instant Verdicts**: Clear color-coded queue status (Safe, Caution, Imminent Adhan) and live countdown HUD. |
| **Inconsistent Habits**: Difficulty maintaining 5 daily prayers on time across busy gaming schedules. | **Discipline Heatmap**: Visual 12-week GitHub-style matrix, streak counters, and habit metrics that celebrate spiritual consistency. |
| **Intrusive Apps**: Prayer apps with advertisements, paywalls, and location tracking violate privacy. | **Zero Ads, Zero Tracking**: 100% offline, free, open-source, and private on-device calculation. |

---

## Key Capabilities

### Smart Queue Decision Engine

The core engine computes the uninterrupted gaming window before the next prayer closes:

$$\text{Available Window} = \text{Time Until Adhan} - \text{Safety Buffer}$$

```
                [ CURRENT TIME ] ─────────────────────────► [ ADHAN ]
                       │                                       │
                       ├──────── Available Window ─────────────┤
                       │                                       │
                [ CURRENT TIME ] ───► [ MATCH ] ───► [ BUFFER ] ───► [ ADHAN ]
                                        ▲ Safe to Queue ▲
```

- **Verdict Classifications**:
  - `Safe to Queue`: Ample time to complete a full match without rushing.
  - `Caution / Quick Modes Only`: Switch to shorter formats (e.g. Swiftplay, ARAM, Spike Rush).
  - `Imminent Adhan / Stop & Pray`: Prayer is imminent or due. Complete Wudu and pray first.
- **Overtime and Variance Handling**: Automatically accounts for competitive overtime (e.g. infinite OT in Valorant, MR12 OT in CS2, Golden Goal in Rocket League).
- **Protection Buffer Levels**:
  - **Relaxed (5 min buffer)**: Maximizes playtime for experienced players.
  - **Balanced (10 min buffer - Recommended)**: Standard comfortable margin for Wudu and preparation.
  - **Strict (15 min buffer)**: Extra time for congregational mosque attendance (*Jama'ah*).

---

### High-Precision Astronomical Prayer Engine

- **Solar Algorithms**: Powered by the astronomical positioning engine `adhan` using on-device GPS or manual city selection.
- **Preconfigured Global Cities**: 40+ major metropolitan areas across MENA, Europe, North America, Central Asia, South Asia, and Southeast Asia.
- **Supported Calculation Authorities**:

<details>
<summary><strong>View All 11 Supported Calculation Methods</strong></summary>

| Calculation Authority | Region / Standard |
| :--- | :--- |
| Muslim World League (MWL) | Europe, Far East, General |
| Umm Al-Qura University, Makkah | Saudi Arabia & Arabian Peninsula |
| Egyptian General Authority of Survey | Egypt, North Africa, Middle East |
| University of Islamic Sciences, Karachi | Pakistan, Bangladesh, India, Afghanistan |
| Islamic Society of North America (ISNA) | USA, Canada |
| Diyanet İşleri Başkanlığı | Turkey |
| Gulf Region Authority | UAE, Oman |
| Ministry of Awqaf | Kuwait |
| Qatar General Authority | Qatar |
| Majlis Ugama Islam Singapura (MUIS) | Singapore |
| Shia Ithna-Ashari (Leva Institute) | Shia / Jafari Juristic Standard |

</details>

- **Asr Juristic Methods**: Standard / Majority (Shafi'i, Maliki, Hanbali, Ja'fari — 1:1 shadow) and Hanafi (2:1 shadow).
- **Specialized Modes**:
  - **Jumu'ah Mode**: Automatically expands Friday Dhuhr buffers to accommodate the sermon (*Khutbah*) and congregational prayer.
  - **Fajr Protection Mode**: High-priority alert threshold to protect dawn prayer habits.

---

### 5-Prayer Consistency Heatmap

- **12-Week (84-Day) Consistency Matrix**: A GitHub-style daily habit heatmap covering all 5 prayers: **Fajr, Dhuhr, Asr, Maghrib, and Isha**.
- **Prayer Status Classifications**:
  - `On-Time`: Prayed within the prescribed window.
  - `Jama'ah`: Performed in congregation at the mosque.
  - `Late`: Completed before the subsequent prayer window, but delayed.
  - `Missed`: Unperformed prayer.
- **Spiritual Diary & Reflection Notes**: Attach personal reflections, Quran Ayah notes, or daily gaming logs to each prayer entry.
- **Discipline Metrics**: Tracks protected prayers, avoided risky queues, and intentional gaming pauses.

---

### Preconfigured Game Catalog and Custom Creator

<details open>
<summary><strong>Preconfigured AAA & Mobile Titles (20 Games)</strong></summary>

| Title | Category | Configured Modes & Durations |
| :--- | :--- | :--- |
| **Valorant** | Competitive FPS | Ranked (40m), Unrated (35m), Swiftplay (15m), Spike Rush (8m) |
| **League of Legends** | Competitive MOBA | Ranked Solo/Duo (35m), Normal Draft (30m), ARAM (20m), Arena (15m) |
| **Counter-Strike 2** | Competitive FPS | Premier / Comp (40m), Wingman (15m), Casual / DM (10m) |
| **Rocket League** | Competitive Sports | Ranked 2v2/3v3 (7m), Scheduled Tournament (35m), Casual (6m) |
| **Fortnite** | Battle Royale | Ranked BR (22m), Casual / Zero Build (18m), Creative (20m) |
| **Apex Legends** | Battle Royale | Ranked BR (20m), Mixtape / Gun Run (12m) |
| **Overwatch 2** | Hero Shooter | Competitive Role Queue (20m), Quick Play / Arcade (10m) |
| **Dota 2** | Competitive MOBA | Ranked All Pick (45m), Turbo Mode (25m) |
| **Rainbow Six Siege** | Tactical Shooter | Ranked / Standard (30m), Quick Match (12m) |
| **EA Sports FC 25** | Sports | UT Champions / Rivals (18m), Career Mode (15m) |
| **Call of Duty: Warzone** | Battle Royale | Battle Royale Squads (25m), Resurgence / Plunder (15m) |
| **Minecraft** | Sandbox / Survival | Survival (45m), Hardcore (60m), Bedwars / PvP (15m) |
| **GTA V / FiveM** | Roleplay / Action | FiveM Roleplay (60m), Online Heists (35m), Story Mode (30m) |
| **Terraria** | Sandbox / Co-Op | Adventure (30m), Boss Fight Progression (15m) |
| **Stardew Valley** | Simulation / Co-Op | In-Game Day Cycle (15m), Co-Op Farm Session (40m) |
| **Roblox** | Multiplayer / Casual | Casual Obby (20m), Competitive Rivals (12m) |
| **Brawl Stars** | Mobile Competitive | Ranked / Power League (6m), Showdown (4m) |
| **Clash Royale** | Mobile Strategy | Trophy Road (5m), 2v2 / Party (4m) |
| **Clash of Clans** | Mobile Strategy | Multiplayer Attack (4m), Clan War Attack (4m) |
| **Genshin Impact** | Action RPG | Daily Commissions & Resin (15m), Spiral Abyss (20m) |

</details>

- **Custom Game Builder**: Add any title, assign icons, and configure custom activities with minimum/maximum durations, pausability (`canPause: true/false`), and commitment levels.

---

### 11-Theme Matrix and Lighting Engine

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             THEME MATRIX (11)                               │
├───────────────────────────────┬──────────────────────────────┬──────────────┤
│ 5 Dark Themes                 │ 5 Light Themes               │ Tactical     │
├───────────────────────────────┼──────────────────────────────┼──────────────┤
│ • Midnight (Deep Navy)        │ • Dawn (Sunrise Coral)       │ • Tactical   │
│ • OLED Minimal (Pure Black)   │ • Arctic (Glacial Blue)      │   (Spec-Ops  │
│ • Crimson (Gamer Ruby Red)    │ • Sand (Dune Gold & Ivory)   │    Lime)     │
│ • Forest (Spruce Emerald)     │ • Sky (Daylight Cyan)        │              │
│ • Ember (Roasted Charcoal)    │ • Lavender (Soft Violet)     │              │
└───────────────────────────────┴──────────────────────────────┴──────────────┘
```

- **Dynamic Sunrise/Sunset Transitions**: Automatically transitions between light themes during daytime and dark themes after Maghrib.

---

### Internationalization and RTL Support

Pray Then Play includes full bidirectional layout engines for **10 major world languages**:

| Language | Code | Direction | Native Name |
| :--- | :--- | :--- | :--- |
| Arabic | `ar` | Right-to-Left (RTL) | العربية |
| English | `en` | Left-to-Right (LTR) | English |
| German | `de` | Left-to-Right (LTR) | Deutsch |
| Spanish | `es` | Left-to-Right (LTR) | Español |
| French | `fr` | Left-to-Right (LTR) | Français |
| Indonesian | `id` | Left-to-Right (LTR) | Bahasa Indonesia |
| Malay | `ms` | Left-to-Right (LTR) | Bahasa Melayu |
| Russian | `ru` | Left-to-Right (LTR) | Русский |
| Turkish | `tr` | Left-to-Right (LTR) | Türkçe |
| Urdu | `ur` | Right-to-Left (RTL) | اردو |

---

### Native Android Widgets

Built using Android `RemoteViews` for minimal battery consumption and instant updating:

1. **Gamer Command Center (4×2)**: Next Salah countdown, streak indicator, active buffer gauge, and instant queue safety check.
2. **Today's Salah Timeline (4×1)**: 5-column daily prayer tracker with active prayer highlights and live countdown badges.
3. **Safe Gaming Modes (4×2)**: Dynamic recommendations showing games and modes from your library that fit within your current window.
4. **Salah Quick Status (2×2)**: Compact countdown tile with prominent safety status badge.

---

### Desktop Integration

Optimized for competitive desktop operating systems (Windows, macOS, Linux):
- **System Tray Minimization**: Runs in the background with native notifications.
- **Windows Startup**: Optional start-on-boot configuration.
- **Zero Overhead**: Ultra-low memory footprint (< 40 MB RAM, 0% idle CPU) ensuring no FPS drops in game.

---

### Privacy and Offline Architecture

- **No Accounts Required**: No email, passwords, or cloud sign-in.
- **Zero Telemetry**: No third-party trackers, analytics frameworks, or external beacons.
- **Local Persistence**: All logs, reflection notes, and preferences remain encrypted strictly on your local device.

---

## Technical Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                      │
│   Flutter UI • Material 3 • Glassmorphism • 11 Themes      │
├────────────────────────────────────────────────────────────┤
│                     STATE MANAGEMENT                       │
│    Riverpod 2.6 (Notifiers, StateProviders, Selectors)     │
├────────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                         │
│  Decision Engine • Prayer Calculation • Overtime Variance  │
├────────────────────────────────────────────────────────────┤
│                    CORE SERVICES LAYER                     │
│  PrayerService • StorageService • WidgetService • Desktop  │
├────────────────────────────────────────────────────────────┤
│                 PLATFORM INTEGRATION LAYER                 │
│  Android RemoteViews • Windows Tray & WindowManager        │
└────────────────────────────────────────────────────────────┘
```

| Component | Technology | Role |
| :--- | :--- | :--- |
| **Core Framework** | Flutter 3.24+ / Dart 3.5+ | Cross-platform client codebase |
| **State Management** | `flutter_riverpod` (2.6.1) | Decoupled reactive state architecture |
| **Navigation** | `go_router` (14.8.1) | Declarative URL and shell routing |
| **Astronomical Math** | `adhan` (2.0.0+) | Solar positioning and prayer calculations |
| **Android Widgets** | `home_widget` | Native RemoteViews widget binding |
| **Persistence** | `shared_preferences` | Key-value local storage |
| **Desktop Tray** | `tray_manager`, `window_manager` | System tray and window controls |
| **Localization** | Custom JSON Bundles | 10-language RTL/LTR engine |

---

## Project Directory Structure

```
pray-then-play-app/
├── android/                             # Android native host & RemoteViews
│   └── app/src/main/
│       ├── kotlin/                      # AppWidget Provider implementations
│       └── res/layout/                  # Native widget XML layouts (4 widgets)
├── assets/
│   ├── branding/                        # Logos, vector crests, and store graphics
│   └── icons/                           # 22+ authentic game icons (PNG & SVG)
├── lib/
│   ├── app/                             # GoRouter routing & 11-theme definitions
│   ├── core/
│   │   ├── constants/                   # Global constants, city data & game catalog
│   │   ├── localization/                # 10 translation files & RTL helpers
│   │   ├── models/                      # GameProfile, GamingWindow, PrayerRecord
│   │   ├── providers/                   # Riverpod state providers & evaluators
│   │   ├── services/                    # PrayerService, LocationService, StorageService
│   │   └── widgets/                     # Shared glassmorphic UI components
│   ├── features/
│   │   ├── game_profiles/               # Game catalog & custom activity builder
│   │   ├── heatmap/                     # 12-week consistency habit matrix
│   │   ├── home/                        # Main dashboard & prayer countdown HUD
│   │   ├── onboarding/                  # First-run setup wizard
│   │   ├── prayer_times/                # Monthly prayer schedules & city selector
│   │   ├── queue_check/                 # Queue safety calculator & evaluator
│   │   └── settings/                    # Preferences, themes, buffers, and audio
│   └── main.dart                        # Application bootstrap
└── pubspec.yaml                         # Dependency definitions
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`v3.24.0` or higher)
- [Dart SDK](https://dart.dev/get-started) (`v3.5.0` or higher)
- [Java Development Kit (JDK 17)](https://www.oracle.com/java/technologies/downloads/#java17)
- Android Studio / VS Code with Flutter extension
- *(Optional for Windows build)* Visual Studio 2022 with C++ desktop development tools

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/TryOmar/pray-then-play.git
   cd pray-then-play/pray-then-play-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Launch on your preferred platform:**
   ```bash
   # Android
   flutter run -d android

   # Windows Desktop
   flutter run -d windows

   # Flutter Web
   flutter run -d chrome
   ```

### Building Production Binaries

```bash
# Android Universal APK
flutter build apk --release

# Android App Bundle (AAB for Google Play)
flutter build appbundle --release

# Windows Desktop Executable
flutter build windows --release

# Flutter Web Client
flutter build web --release --base-href "/pray-then-play-website/app/"
```

---

## The Pray Then Play Ecosystem

Pray Then Play spans multiple repositories and integration points:

```
                            ┌───────────────────────────────┐
                            │    PRAY THEN PLAY ECOSYSTEM   │
                            └───────────────┬───────────────┘
                                            │
        ┌───────────────────────────────────┼───────────────────────────────────┐
        │                                   │                                   │
        ▼                                   ▼                                   ▼
┌───────────────────────┐       ┌───────────────────────┐       ┌───────────────────────┐
│   FLUTTER CLIENT      │       │   DISCORD BOT         │       │   WEB & DOWNLOADS     │
│  Android, Desktop,    │       │  Automated server bot │       │  Interactive queue    │
│  Web & Native Widgets │       │  voice alerts & LFG   │       │  simulator & portal   │
└───────────────────────┘       └───────────────────────┘       └───────────────────────┘
```

1. **App Repository (`pray-then-play`)**: Cross-platform Flutter client with widgets and desktop tray.
2. **Website Repository (`pray-then-play-website`)**: High-performance landing page and interactive simulator.
3. **Discord System (`pray-then-play-discord`)**: Community Discord bot with automated prayer reminders and queue checking slash commands.

---

## Contributing

Contributions are welcome. Whether you are adding a new game profile, refining a translation, or enhancing widgets:

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/new-game-profile`
3. Commit your changes: `git commit -m 'feat: Add EA Sports FC 25 profile'`
4. Push to the branch: `git push origin feature/new-game-profile`
5. Open a Pull Request.

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Stay on time. Play with peace of mind.**

Built for the global Muslim gaming community.

</div>
