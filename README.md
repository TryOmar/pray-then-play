# 🎮 Pray Then Play — Stay on time. Play with peace of mind.

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Windows%20%7C%20Web-blue.svg?style=for-the-badge)

**A smart gaming companion and prayer tracker tailored specifically for Muslim gamers.**  
*Salah first. Gaming second. Stay on time. Play with peace of mind.*

</div>

---

## 🌟 Overview

**Pray Then Play** (*PTP*) bridges the gap between gaming sessions and spiritual discipline. By calculating precise prayer times and comparing them with your game activities and session durations, Pray Then Play provides intelligent queue safety recommendations so you always know when to queue, when to pause, and when to pray.

---

## ✨ Key Features

### 🛡️ Smart Queue Check & Decision Engine
- **Queue Risk Assessment**: Calculates exact remaining time until the next prayer minus match buffer duration.
- **Dynamic Status Flags**:
  - 🟢 **Safe to Play**: Ample time to finish your full match without rushing.
  - 🟡 **Caution / Short Session Only**: Recommends swiftplay, casual, or shorter match types.
  - 🔴 **Risky Queue / Stop & Pray**: Warns against starting long commitment matches right before Adhan.
- **In-Match Timer & Overlay**: Track your active gaming match against prayer deadlines in real-time.

### 🕌 Accurate Prayer Times
- Powered by the **Adhan** calculation engine.
- Configurable calculation methods:
  - Muslim World League
  - Egyptian General Authority
  - University of Islamic Sciences (Karachi)
  - Umm Al-Qura (Makkah)
  - Dubai / Islamic Society of North America (ISNA)
  - Hanafi & Shafi'i / Standard Asr calculation methods.

### 🎮 Custom Game Profiles & Library
- **22+ Predefined Competitive & Casual Titles**:
  - *Valorant, League of Legends, Counter-Strike 2, Dota 2, Overwatch 2, Fortnite, Apex Legends, Rocket League, Rainbow Six Siege, Call of Duty Warzone, EA SPORTS FC 24, Mobile Legends, PUBG Mobile, Minecraft, Terraria, Stardew Valley, Roblox, Steam, Brawl Stars, Clash Royale, Clash of Clans, Genshin Impact*.
- **Custom Game Builder**: Add your own games, custom modes, estimated match times, and commitment levels.

### 📊 Consistency Heatmap & Achievements
- **Multi-State Prayer Tracking**: Track On-Time, Late, or In-Progress prayers.
- **Discipline Heatmap**: Visual GitHub-style consistency grid showing your prayer habits across weeks and months.
- **Gamer Achievements**: Unlock milestones like *First Step*, *Queue Discipline*, *Prayer Protector*, and *Night Warden*.

### 🎨 Dark Gaming Glassmorphism UI
- Tailored for high-end OLED displays and gaming environments.
- Brand-accented glowing game badges with authentic high-resolution icons.
- Responsive layout supporting Mobile (iOS/Android) and Web.

---

## 🏗️ Architecture & Technology Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.5+ |
| **State Management** | `flutter_riverpod` (Riverpod 2.5) |
| **Prayer Calculations** | `adhan` engine with Geolocation |
| **Local Storage** | `shared_preferences` & `hive_flutter` |
| **Routing** | `go_router` |
| **UI & Charts** | `fl_chart`, `flutter_svg`, `google_fonts`, `percent_indicator` |
| **Notifications** | `flutter_local_notifications` & `timezone` |

---

## 📁 Project Directory Structure

```
d:\Projects\gamer-salah\
├── assets/
│   ├── icons/                  # 22+ high-res game icons (PNG & SVG)
│   └── images/                 # App artwork & graphic assets
├── lib/
│   ├── app/
│   │   ├── app.dart            # Root MaterialApp & Riverpod provider scope
│   │   ├── router.dart         # GoRouter configuration
│   │   └── theme.dart          # Cyberpunk dark theme design system
│   ├── core/
│   │   ├── constants/          # Game catalog, prayer rules, & app keys
│   │   ├── models/             # GameProfile, GameMode, PrayerRecord
│   │   ├── providers/          # Riverpod state providers
│   │   ├── services/           # Prayer, storage, & notification services
│   │   └── widgets/            # GameIconWidget & reusable components
│   ├── features/
│   │   ├── game_profiles/      # Library management & custom game creator
│   │   ├── heatmap/            # Consistency history & discipline stats
│   │   ├── home/               # Dashboard, next prayer hero, & timeline
│   │   ├── onboarding/         # Setup wizard (city, games, calculations)
│   │   ├── queue_check/        # Instant queue risk evaluator
│   │   └── session_planning/   # Multi-match gaming planner
│   └── main.dart               # App entrypoint
├── tool/                       # Asset management & icon utilities
└── pubspec.yaml                # Dependencies & asset declarations
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.24.0 or higher)
- [Dart SDK](https://dart.dev/get-started) (v3.5.0 or higher)
- Google Chrome (for Web testing) or Android/iOS emulator

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/gamer-salah.git
   cd gamer-salah
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Web:**
   ```bash
   flutter run -d chrome
   ```
   *or serve locally on port 8080:*
   ```bash
   flutter run -d web-server --web-hostname=localhost --web-port=8080
   ```

4. **Run on Mobile Device / Emulator:**
   ```bash
   flutter run
   ```

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
