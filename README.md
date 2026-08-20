# 🎮 Pray Then Play — Stay on time. Play with peace of mind.

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-blue.svg?style=for-the-badge)

**A smart gaming companion and prayer tracker tailored specifically for Muslim gamers.**  
*Salah first. Gaming second. Stay on time. Play with peace of mind.*

</div>

---

## 🌟 Overview

**Pray Then Play** (*PTP*) bridges the gap between competitive gaming and spiritual discipline. By calculating astronomical prayer times and comparing them with game match durations and customizable safety buffers, Pray Then Play provides intelligent queue safety verdicts so you always know when to queue, when to pause, and when to pray.

---

## ✨ Key Features

### 🛡️ Smart Queue Check & Decision Engine
- **Queue Risk Assessment**: Calculates exact remaining uninterrupted gaming time before the next prayer buffer.
- **Dynamic Status Verdicts**:
  - 🟢 **Safe to Play**: Ample time to finish your full match without rushing.
  - 🟡 **Caution / Quick Mode Only**: Recommends swiftplay, casual, or shorter game modes.
  - 🔴 **Imminent Adhan / Stop & Pray**: Warns against starting commitment matches right before Adhan.
- **Overtime Risk Protection**: Evaluates overtime variance for ranked modes in Valorant, CS2, and Rocket League.

### 🕌 Accurate Global Prayer Times
- Powered by astronomical calculation engines based on GPS or selected global city.
- Supports all major calculation methods:
  - Muslim World League (MWL)
  - Umm Al-Qura (Makkah)
  - Egyptian General Authority
  - University of Islamic Sciences (Karachi)
  - ISNA (North America), Diyanet (Turkey), Gulf Region, and more.
- Flexible Asr calculation: Standard (Shafi'i, Maliki, Hanbali) and Hanafi madhhabs.
- Seamless 12-Hour (AM/PM) and 24-Hour time format support across all screens and widgets.

### 📱 Android Home Screen Widgets
Glanceable countdowns directly from your Android launcher without opening the app:
1. **Gamer Command Center (4×2)**: Next Salah countdown, streak indicator, and instant queue safety check.
2. **Today's Salah Timeline (4×1)**: 5-column daily prayer tracker with active highlights and calibrated spacing.
3. **Safe Gaming Modes (4×2)**: Real-time recommendations with authentic game icons matching your available window.
4. **Salah Quick Status (2×2)**: Compact countdown and safety status badge.

### 📊 5-Prayer Habit Heatmap & Reflection
- **Discipline Heatmap**: Visual GitHub-style consistency matrix tracking Fajr, Dhuhr, Asr, Maghrib, and Isha over 12 weeks.
- **Daily Prayer Logging**: Record *On-Time*, *Jama'ah (Mosque)*, *Late*, or *Missed* status with personal reflection notes.
- **Streaks & Balance**: Track consecutive on-time prayer streaks and ensure gaming never overlaps with Adhan.

### 🎮 Custom Game Profiles & Library
- **Preconfigured Profiles**: *Valorant, League of Legends, CS2, Rocket League, Minecraft, Fortnite, Apex Legends, Brawl Stars, Dota 2, EA Sports FC, Overwatch 2, PUBG, Rainbow Six Siege, and more*.
- **Custom Game Builder**: Add any title, custom mode, estimated match duration, and buffer profile.

### 🔒 100% Private & Offline-Ready
- Zero tracking, telemetry, or user account requirements.
- GPS coordinates are processed strictly on-device to calculate local prayer times.

---

## 🏗️ Architecture & Technology Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.5+ |
| **State Management** | `flutter_riverpod` (Riverpod 2.5) |
| **Prayer Engine** | `adhan` with astronomical positioning |
| **Home Widgets** | `home_widget` (Native Android AppWidget & RemoteViews) |
| **Local Storage** | `shared_preferences` & `hive_flutter` |
| **Routing** | `go_router` |
| **Notifications** | `flutter_local_notifications` & `timezone` |

---

## 📁 Project Directory Structure

```
pray-then-play/
├── android/                    # Android project, manifest & RemoteViews widget layouts
│   └── app/src/main/res/layout/ # Widget layout XMLs (ptp_widget_*.xml)
├── assets/
│   ├── branding/               # Official logos, store banners & app icons
│   │   └── store/screenshots/  # 1080x2400 Google Play showcase screenshots
│   └── icons/                  # 22+ high-res game icons (PNG & SVG)
├── lib/
│   ├── app/                    # Theme, routing, and shell navigation
│   ├── core/
│   │   ├── constants/          # Game catalog, prayer rules, & app keys
│   │   ├── models/             # GameProfile, GameMode, PrayerRecord
│   │   ├── services/           # Prayer, home widget, storage, & notification services
│   │   └── utils/              # TimeUtils & helper formatters
│   └── features/
│       ├── game_profiles/      # Library management & custom game creator
│       ├── heatmap/            # Consistency history & reflection notes
│       ├── home/               # Dashboard, next prayer countdown, & 24h timeline
│       ├── onboarding/         # Setup wizard (city, games, calculations)
│       └── queue_check/        # Instant queue risk evaluator
└── pubspec.yaml                # Dependencies & asset declarations
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.24.0 or higher)
- [Dart SDK](https://dart.dev/get-started) (v3.5.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Java JDK 17

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/pray-then-play.git
   cd pray-then-play
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Connected Android Device / Emulator:**
   ```bash
   flutter run
   ```

4. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```

5. **Build Release Android App Bundle (`.aab`) for Google Play:**
   ```bash
   flutter build appbundle --release
   ```

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
