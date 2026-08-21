import 'dart:io';

void main() async {
  print('🚀 Initializing Pray Then Play Ecosystem Generators...\n');

  final baseDir = r'D:\Projects\pray-then-play-ecosystem';
  final webDir = '$baseDir\\pray-then-play-website';
  final discordDir = '$baseDir\\pray-then-play-discord';

  // Ensure directories
  Directory('$webDir\\styles').createSync(recursive: true);
  Directory('$webDir\\js').createSync(recursive: true);
  Directory('$webDir\\downloads').createSync(recursive: true);
  Directory('$discordDir\\src\\commands').createSync(recursive: true);
  Directory('$discordDir\\src\\embeds').createSync(recursive: true);
  Directory('$discordDir\\src\\scripts').createSync(recursive: true);

  // 1. Write Website HTML
  print('📄 Generating Website HTML...');
  File('$webDir\\index.html').writeAsStringSync('''<!DOCTYPE html>
<html lang="en" class="dark">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Pray Then Play — Islamic Prayer Times & Gaming Safety Companion</title>
  <meta name="description" content="Never miss Salah for a match again. Pray Then Play combines smart match risk calculators, dynamic 24H HUD timelines, consistency heatmaps, and native Windows/Android support." />
  
  <meta property="og:title" content="Pray Then Play — The #1 Islamic Companion for Gamers" />
  <meta property="og:description" content="Smart queue safety calculations, 24H HUD timeline, prayer streaks, and unobtrusive background desktop & mobile companions." />
  <meta property="og:image" content="assets/images/app_icon.png" />
  <meta property="og:type" content="website" />
  <meta name="theme-color" content="#0B1020" />

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Amiri:wght@400;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
  
  <link rel="stylesheet" href="styles/main.css" />
  <link rel="icon" type="image/png" href="assets/images/app_icon.png" />
</head>
<body>
  <div class="ambient-glow glow-emerald"></div>
  <div class="ambient-glow glow-cyan"></div>
  <div class="ambient-glow glow-amber"></div>

  <nav class="navbar">
    <div class="nav-container">
      <a href="#" class="nav-brand">
        <img src="assets/images/logo_icon.png" alt="Pray Then Play Logo" class="brand-icon" />
        <span class="brand-text">PRAY <span class="text-emerald">THEN</span> PLAY</span>
      </a>

      <div class="nav-links">
        <a href="#features" class="nav-link">Features</a>
        <a href="#calculator" class="nav-link">Live Queue Check</a>
        <a href="#downloads" class="nav-link">Downloads</a>
        <a href="#discord" class="nav-link">Discord</a>
        <a href="#faq" class="nav-link">FAQ</a>
      </div>

      <div class="nav-actions">
        <a href="#downloads" class="btn btn-primary btn-sm">
          <i class="fa-brands fa-windows"></i> Get App
        </a>
      </div>
    </div>
  </nav>

  <header class="hero-section">
    <div class="container hero-grid">
      <div class="hero-content">
        <div class="hero-badge">
          <span class="badge-dot"></span>
          <span class="badge-text">v2.0 Native Windows & Android Released</span>
        </div>

        <h1 class="hero-title">
          Never Miss Salah <br />
          <span class="gradient-text">For A Match Again.</span>
        </h1>

        <p class="hero-subtitle">
          The intelligent prayer companion built specifically for gamers. Know exactly if you have time for another ranked match with live risk assessments, 24H HUD timelines, and unobtrusive tray notifications.
        </p>

        <div class="hero-cta-group">
          <a href="downloads/PrayThenPlay-Setup-v2.0.0-x64.exe" class="btn btn-emerald btn-lg" download>
            <i class="fa-brands fa-windows"></i>
            <div class="btn-text-group">
              <span class="btn-sub">Windows 10/11</span>
              <span class="btn-main">Download Setup (15.3 MB)</span>
            </div>
          </a>

          <a href="downloads/PrayThenPlay-v2.0.0.apk" class="btn btn-glass btn-lg" download>
            <i class="fa-brands fa-android"></i>
            <div class="btn-text-group">
              <span class="btn-sub">Direct APK</span>
              <span class="btn-main">Download Android</span>
            </div>
          </a>

          <a href="http://localhost:3000" target="_blank" class="btn btn-outline btn-lg">
            <i class="fa-solid fa-globe"></i>
            <div class="btn-text-group">
              <span class="btn-sub">Zero Install</span>
              <span class="btn-main">Launch Web App</span>
            </div>
          </a>
        </div>

        <div class="hero-stats">
          <div class="stat-item">
            <i class="fa-solid fa-bolt text-emerald"></i>
            <span>Real-time Adhan Calculation</span>
          </div>
          <div class="stat-item">
            <i class="fa-solid fa-shield-halved text-amber"></i>
            <span>Custom Safety Buffer</span>
          </div>
          <div class="stat-item">
            <i class="fa-solid fa-gamepad text-cyan"></i>
            <span>15+ Preset Game Profiles</span>
          </div>
        </div>
      </div>

      <div class="hero-visual">
        <div class="hud-card glass-panel">
          <div class="hud-header">
            <div class="hud-status-badge status-safe" id="heroRiskBadge">
              <i class="fa-solid fa-circle-check"></i>
              <span id="heroRiskText">SAFE TO PLAY</span>
            </div>
            <div class="hud-clock" id="liveClock">12:45:00 PM</div>
          </div>

          <div class="hud-prayer-target">
            <span class="prayer-label">NEXT PRAYER</span>
            <h3 class="prayer-name" id="heroNextPrayer">Asr in 52m</h3>
            <p class="prayer-time" id="heroPrayerTime">Adhan at 3:47 PM • Window ends 6:47 PM</p>
          </div>

          <div class="mini-timeline">
            <div class="timeline-bar">
              <div class="timeline-fill" style="width: 65%;"></div>
              <div class="timeline-marker" style="left: 65%;">
                <span class="marker-label">NOW</span>
              </div>
            </div>
            <div class="timeline-legend">
              <span>Dhuhr (12:25 PM)</span>
              <span class="text-emerald font-semibold">Asr (3:47 PM)</span>
              <span>Maghrib (6:47 PM)</span>
            </div>
          </div>

          <div class="hud-footer">
            <div class="hud-game-active">
              <img src="assets/icons/valorant.svg" alt="Valorant" class="game-icon-sm" />
              <div class="game-info">
                <span class="game-title">Valorant (Competitive)</span>
                <span class="game-duration">Avg: 35m + 10m buffer</span>
              </div>
            </div>
            <div class="hud-verdict text-emerald">
              <i class="fa-solid fa-circle-play"></i> Good for 1 match
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>

  <section id="calculator" class="section calculator-section">
    <div class="container">
      <div class="section-header text-center">
        <span class="section-tag">INTERACTIVE SIMULATOR</span>
        <h2 class="section-title">Try The Queue Safety Algorithm</h2>
        <p class="section-subtitle">Pick your game and test how Pray Then Play protects your Salah schedule before you hit Start Queue.</p>
      </div>

      <div class="calculator-box glass-panel">
        <div class="calc-grid">
          <div class="calc-controls">
            <div class="form-group">
              <label><i class="fa-solid fa-gamepad"></i> Select Game</label>
              <div class="game-selector-grid" id="gameButtons">
                <button class="game-btn active" data-id="valorant" data-min="35" data-name="Valorant" data-icon="assets/icons/valorant.svg">
                  <img src="assets/icons/valorant.svg" alt="Valorant" /> Valorant (35m)
                </button>
                <button class="game-btn" data-id="league" data-min="30" data-name="League of Legends" data-icon="assets/icons/league.svg">
                  <img src="assets/icons/league.svg" alt="League" /> League (30m)
                </button>
                <button class="game-btn" data-id="cs2" data-min="40" data-name="Counter-Strike 2" data-icon="assets/icons/cs2.svg">
                  <img src="assets/icons/cs2.svg" alt="CS2" /> CS2 (40m)
                </button>
                <button class="game-btn" data-id="fortnite" data-min="22" data-name="Fortnite" data-icon="assets/icons/fortnite.svg">
                  <img src="assets/icons/fortnite.svg" alt="Fortnite" /> Fortnite (22m)
                </button>
                <button class="game-btn" data-id="minecraft" data-min="45" data-name="Minecraft Survival" data-icon="assets/icons/minecraft.svg">
                  <img src="assets/icons/minecraft.svg" alt="Minecraft" /> Minecraft (45m)
                </button>
                <button class="game-btn" data-id="dota" data-min="45" data-name="Dota 2" data-icon="assets/icons/dota.svg">
                  <img src="assets/icons/dota.svg" alt="Dota" /> Dota 2 (45m)
                </button>
              </div>
            </div>

            <div class="form-group">
              <div class="slider-header">
                <label><i class="fa-solid fa-hourglass-half"></i> Minutes Remaining Until Next Prayer</label>
                <span class="slider-val text-emerald font-bold" id="timeRemainingVal">55 min</span>
              </div>
              <input type="range" id="timeRemainingInput" min="5" max="180" value="55" class="range-slider" />
            </div>

            <div class="form-group">
              <div class="slider-header">
                <label><i class="fa-solid fa-shield"></i> Wudu & Safety Buffer</label>
                <span class="slider-val text-amber font-bold" id="bufferVal">10 min</span>
              </div>
              <input type="range" id="bufferInput" min="0" max="30" value="10" class="range-slider" />
            </div>
          </div>

          <div class="calc-result-panel" id="calcResultPanel">
            <div class="result-badge status-safe" id="calcStatusBadge">
              <i class="fa-solid fa-circle-check" id="calcStatusIcon"></i>
              <span id="calcStatusTitle">SAFE TO PLAY</span>
            </div>

            <div class="result-equation">
              <div class="eq-item">
                <span class="eq-label">Match Duration</span>
                <span class="eq-val" id="calcMatchDuration">35m</span>
              </div>
              <span class="eq-op">+</span>
              <div class="eq-item">
                <span class="eq-label">Safety Buffer</span>
                <span class="eq-val text-amber" id="calcBufferDisplay">10m</span>
              </div>
              <span class="eq-op">=</span>
              <div class="eq-item">
                <span class="eq-label">Required Total</span>
                <span class="eq-val text-emerald font-bold" id="calcRequiredTotal">45m</span>
              </div>
            </div>

            <div class="result-verdict-box" id="calcVerdictBox">
              <h4 id="calcVerdictHeadline">You have plenty of time!</h4>
              <p id="calcVerdictDesc">You will finish your match approximately 10 minutes before the Adhan call. Safe to start another queue.</p>
            </div>

            <div class="result-time-bar">
              <div class="bar-track">
                <div class="bar-match" id="barMatch" style="width: 63%;">Match (35m)</div>
                <div class="bar-buffer" id="barBuffer" style="width: 18%;">Buffer (10m)</div>
                <div class="bar-spare" id="barSpare" style="width: 19%;">Spare (10m)</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section id="features" class="section features-section">
    <div class="container">
      <div class="section-header text-center">
        <span class="section-tag">ENGINEERED FOR GAMERS</span>
        <h2 class="section-title">Key Features That Protect Your Faith</h2>
        <p class="section-subtitle">Designed from the ground up for high-focus gamers who need fast, zero-friction prayer awareness.</p>
      </div>

      <div class="features-grid">
        <div class="feature-card glass-panel">
          <div class="feature-icon-box bg-emerald-dim text-emerald">
            <i class="fa-solid fa-shield-virus"></i>
          </div>
          <h3 class="feature-heading">Smart Safety Buffers</h3>
          <p class="feature-desc">
            Never get trapped in overtime or sudden death. The risk calculator reserves time for Wudu and Sunnah before the Adhan starts.
          </p>
        </div>

        <div class="feature-card glass-panel">
          <div class="feature-icon-box bg-cyan-dim text-cyan">
            <i class="fa-solid fa-chart-pie"></i>
          </div>
          <h3 class="feature-heading">24H Dynamic HUD Timeline</h3>
          <p class="feature-desc">
            Instantly visualize your day. View Salah windows, gaming blocks, and upcoming prayers at a single glance with 12H / 24H formatting.
          </p>
        </div>

        <div class="feature-card glass-panel">
          <div class="feature-icon-box bg-amber-dim text-amber">
            <i class="fa-solid fa-fire"></i>
          </div>
          <h3 class="feature-heading">7-State Consistency Heatmap</h3>
          <p class="feature-desc">
            Gamify your consistency with Github-style heatmaps. Track on-time prayers, streaks, and mindful habits throughout the entire year.
          </p>
        </div>

        <div class="feature-card glass-panel">
          <div class="feature-icon-box bg-purple-dim text-purple">
            <i class="fa-brands fa-windows"></i>
          </div>
          <h3 class="feature-heading">Windows System Tray & Startup</h3>
          <p class="feature-desc">
            Runs silently in the Windows background. Double-click tray to check status, right-click to quick-queue, and receive non-intrusive action center toasts.
          </p>
        </div>

        <div class="feature-card glass-panel">
          <div class="feature-icon-box bg-emerald-dim text-emerald">
            <i class="fa-solid fa-layer-group"></i>
          </div>
          <h3 class="feature-heading">Activity-Based Estimations</h3>
          <p class="feature-desc">
            Different modes have different lengths. Choose between Quick Play, Ranked, Battle Royale, or Minecraft Survival with distinct time presets.
          </p>
        </div>

        <div class="feature-card glass-panel">
          <div class="feature-icon-box bg-cyan-dim text-cyan">
            <i class="fa-solid fa-moon"></i>
          </div>
          <h3 class="feature-heading">Multi-Theme Customization</h3>
          <p class="feature-desc">
            Switch between Islamic Emerald, Cyberpunk Neon, Stealth Midnight, Royal Gold, and Crimson aesthetics tailored to match your setup.
          </p>
        </div>
      </div>
    </div>
  </section>

  <section id="downloads" class="section downloads-section">
    <div class="container">
      <div class="section-header text-center">
        <span class="section-tag">CROSS-PLATFORM</span>
        <h2 class="section-title">Download Pray Then Play</h2>
        <p class="section-subtitle">Available on Windows, Android, and directly in your browser.</p>
      </div>

      <div class="downloads-grid">
        <div class="download-card glass-panel popular-card">
          <div class="popular-badge"><i class="fa-solid fa-star"></i> Most Popular for Gamers</div>
          <div class="card-header">
            <i class="fa-brands fa-windows platform-icon text-cyan"></i>
            <div>
              <h3 class="platform-name">Windows Desktop</h3>
              <span class="platform-tag">Windows 10 / 11 (64-bit)</span>
            </div>
          </div>
          <p class="platform-desc">
            Full desktop experience with background system tray, action center toasts, and optional run-at-startup.
          </p>
          <ul class="platform-features">
            <li><i class="fa-solid fa-check text-emerald"></i> 1-Click Setup Installer (.exe)</li>
            <li><i class="fa-solid fa-check text-emerald"></i> Tray icon with live prayer tooltip</li>
            <li><i class="fa-solid fa-check text-emerald"></i> Offline IP Geolocation support</li>
          </ul>
          <a href="downloads/PrayThenPlay-Setup-v2.0.0-x64.exe" class="btn btn-emerald btn-block" download>
            <i class="fa-solid fa-download"></i> Download Setup v2.0.0 (15.3 MB)
          </a>
        </div>

        <div class="download-card glass-panel">
          <div class="card-header">
            <i class="fa-brands fa-android platform-icon text-emerald"></i>
            <div>
              <h3 class="platform-name">Android Mobile</h3>
              <span class="platform-tag">Android 8.0+ (ARM64 / x86_64)</span>
            </div>
          </div>
          <p class="platform-desc">
            Pocket companion with interactive 2x2, 4x2, and 4x4 home screen widgets and precise GPS calculation.
          </p>
          <ul class="platform-features">
            <li><i class="fa-solid fa-check text-emerald"></i> Standalone APK (v2.0.0)</li>
            <li><i class="fa-solid fa-check text-emerald"></i> Home Screen Widget Support</li>
            <li><i class="fa-solid fa-hourglass-half text-amber"></i> Google Play Store (Coming Soon)</li>
          </ul>
          <div class="btn-stack">
            <a href="downloads/PrayThenPlay-v2.0.0.apk" class="btn btn-glass btn-block" download>
              <i class="fa-solid fa-download"></i> Download APK (66.2 MB)
            </a>
            <div class="google-play-pill">
              <i class="fa-brands fa-google-play text-emerald"></i> Google Play Store Release Coming Soon
            </div>
          </div>
        </div>

        <div class="download-card glass-panel">
          <div class="card-header">
            <i class="fa-solid fa-globe platform-icon text-amber"></i>
            <div>
              <h3 class="platform-name">Web Client</h3>
              <span class="platform-tag">Any Modern Browser</span>
            </div>
          </div>
          <p class="platform-desc">
            Zero-installation web edition with local offline storage, quick queue check, and full UI customization.
          </p>
          <ul class="platform-features">
            <li><i class="fa-solid fa-check text-emerald"></i> Instant browser access</li>
            <li><i class="fa-solid fa-check text-emerald"></i> Runs offline with LocalStorage</li>
            <li><i class="fa-solid fa-check text-emerald"></i> PWA Installable</li>
          </ul>
          <a href="http://localhost:3000" target="_blank" class="btn btn-outline btn-block">
            <i class="fa-solid fa-up-right-from-square"></i> Launch Web App
          </a>
        </div>
      </div>
    </div>
  </section>

  <section id="discord" class="section discord-section">
    <div class="container">
      <div class="discord-card glass-panel">
        <div class="discord-content">
          <div class="discord-badge">
            <i class="fa-brands fa-discord"></i> OFFICIAL COMMUNITY
          </div>
          <h2 class="discord-title">Join The Pray Then Play Discord Server</h2>
          <p class="discord-desc">
            Connect with Muslim gamers worldwide. Squad up for ranked matches before Salah, request new game profiles, get instant setup support, and participate in community game nights.
          </p>
          <div class="discord-features-list">
            <span><i class="fa-solid fa-users text-emerald"></i> Active LFG Squad Channels</span>
            <span><i class="fa-solid fa-bell text-amber"></i> Instant Adhan Alerts & Bot</span>
            <span><i class="fa-solid fa-headset text-cyan"></i> 24/7 Voice Lounges</span>
          </div>
          <a href="https://discord.gg/" target="_blank" class="btn btn-discord btn-lg">
            <i class="fa-brands fa-discord"></i> Join Discord Server
          </a>
        </div>
        <div class="discord-graphic">
          <div class="discord-preview-box">
            <div class="discord-msg-header">
              <img src="assets/images/logo_icon.png" alt="Bot" class="discord-avatar" />
              <div>
                <span class="bot-name">Pray Then Play Bot</span>
                <span class="bot-tag">BOT</span>
                <span class="msg-time">Today at 3:45 PM</span>
              </div>
            </div>
            <div class="discord-embed">
              <div class="embed-side-color"></div>
              <div class="embed-body">
                <div class="embed-title"><i class="fa-solid fa-mosque"></i> Salah Reminder: Asr</div>
                <div class="embed-desc">Adhan has commenced for Cairo, Egypt (3:47 PM). Wrap up current matches and prepare for prayer.</div>
                <div class="embed-footer">Pray Then Play • Community Companion</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section id="faq" class="section faq-section">
    <div class="container max-w-3xl">
      <div class="section-header text-center">
        <span class="section-tag">FREQUENTLY ASKED QUESTIONS</span>
        <h2 class="section-title">Everything You Need To Know</h2>
      </div>

      <div class="faq-accordion">
        <details class="faq-item glass-panel" open>
          <summary class="faq-question">
            <span>How does the Queue Safety Risk Calculator work?</span>
            <i class="fa-solid fa-chevron-down faq-icon"></i>
          </summary>
          <div class="faq-answer">
            The calculator compares your desired game session duration (e.g. 35m for Valorant) plus your configurable safety buffer (e.g. 10m for Wudu & Sunnah) against the exact remaining time until the next Adhan call. If your match would extend into the buffer or miss the prayer, it warns you with a clear amber or red alert.
          </div>
        </details>

        <details class="faq-item glass-panel">
          <summary class="faq-question">
            <span>Which prayer calculation methods are supported?</span>
            <i class="fa-solid fa-chevron-down faq-icon"></i>
          </summary>
          <div class="faq-answer">
            Pray Then Play supports all global calculation standards including Egyptian General Authority of Survey, Muslim World League (MWL), Islamic Society of North America (ISNA), Umm al-Qura (Makkah), University of Islamic Sciences (Karachi), and Gulf Region methods, with support for Hanafi and Shafi'i/Hanbali/Maliki Asr juristics.
          </div>
        </details>

        <details class="faq-item glass-panel">
          <summary class="faq-question">
            <span>Can I add my own custom games and activity times?</span>
            <i class="fa-solid fa-chevron-down faq-icon"></i>
          </summary>
          <div class="faq-answer">
            Yes! In the Game Profiles tab, you can add custom games, set your estimated match durations, configure specific game modes (e.g., Ranked vs Casual), and customize safety buffers for each title.
          </div>
        </details>

        <details class="faq-item glass-panel">
          <summary class="faq-question">
            <span>Does the Windows version consume CPU or RAM while gaming?</span>
            <i class="fa-solid fa-chevron-down faq-icon"></i>
          </summary>
          <div class="faq-answer">
            Not at all. When minimized, Pray Then Play runs quietly in the system tray with negligible CPU usage (0%) and minimal RAM footprint, ensuring your gaming FPS remains completely unaffected.
          </div>
        </details>
      </div>
    </div>
  </section>

  <footer class="footer">
    <div class="container">
      <div class="ayah-banner glass-panel text-center">
        <p class="ayah-arabic">حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ</p>
        <p class="ayah-translation">"Guard strictly your prayers, especially the middle prayer, and stand before Allah with devotion." (Surah Al-Baqarah 2:238)</p>
      </div>

      <div class="footer-bottom">
        <div class="footer-brand">
          <img src="assets/images/logo_icon.png" alt="Logo" class="footer-logo" />
          <span>Pray Then Play • Gaming Salah Companion</span>
        </div>

        <div class="footer-links">
          <a href="#features">Features</a>
          <a href="#downloads">Downloads</a>
          <a href="#discord">Discord</a>
          <a href="https://github.com/TryOmar/pray-then-play" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
        </div>

        <div class="footer-copy">
          &copy; 2026 Pray Then Play. All rights reserved. Open source under MIT License.
        </div>
      </div>
    </div>
  </footer>

  <script src="js/app.js"></script>
</body>
</html>
''');

  // 2. Write Main CSS
  print('🎨 Generating Main CSS...');
  File('$webDir\\styles\\main.css').writeAsStringSync('''
:root {
  --bg-dark: #070B14;
  --bg-card: rgba(14, 21, 38, 0.75);
  --bg-card-hover: rgba(20, 30, 55, 0.85);
  --border-color: rgba(255, 255, 255, 0.08);
  --border-glow: rgba(16, 185, 129, 0.35);
  
  --emerald-500: #10B981;
  --emerald-400: #34D399;
  --emerald-dim: rgba(16, 185, 129, 0.15);
  
  --cyan-500: #06B6D4;
  --cyan-400: #22D3EE;
  --cyan-dim: rgba(6, 182, 212, 0.15);
  
  --amber-500: #F59E0B;
  --amber-400: #FBBF24;
  --amber-dim: rgba(245, 158, 11, 0.15);

  --purple-dim: rgba(168, 85, 247, 0.15);
  --rose-500: #F43F5E;
  
  --text-main: #F8FAFC;
  --text-muted: #94A3B8;
  --text-sub: #64748B;
  
  --font-main: 'Outfit', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-body: 'Plus Jakarta Sans', sans-serif;
  --font-arabic: 'Amiri', serif;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
  font-family: var(--font-body);
  background-color: var(--bg-dark);
  color: var(--text-main);
  line-height: 1.6;
}

body {
  position: relative;
  overflow-x: hidden;
  min-height: 100vh;
}

/* Ambient Glows */
.ambient-glow {
  position: fixed;
  border-radius: 50%;
  filter: blur(140px);
  pointer-events: none;
  z-index: 0;
  opacity: 0.25;
}
.glow-emerald {
  width: 500px;
  height: 500px;
  background: var(--emerald-500);
  top: -100px;
  left: -150px;
}
.glow-cyan {
  width: 450px;
  height: 450px;
  background: var(--cyan-500);
  top: 40%;
  right: -150px;
}
.glow-amber {
  width: 400px;
  height: 400px;
  background: var(--amber-500);
  bottom: 0;
  left: 20%;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  position: relative;
  z-index: 1;
}
.max-w-3xl {
  max-width: 800px;
}

/* Typography & Helpers */
h1, h2, h3, h4, .brand-text {
  font-family: var(--font-main);
}
.text-center { text-align: center; }
.text-emerald { color: var(--emerald-400); }
.text-cyan { color: var(--cyan-400); }
.text-amber { color: var(--amber-400); }
.font-semibold { font-weight: 600; }
.font-bold { font-weight: 700; }

.gradient-text {
  background: linear-gradient(135deg, #34D399 0%, #06B6D4 50%, #FBBF24 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Glass Panels */
.glass-panel {
  background: var(--bg-card);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid var(--border-color);
  border-radius: 20px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.glass-panel:hover {
  border-color: rgba(255, 255, 255, 0.15);
  box-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.5);
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 12px 24px;
  border-radius: 12px;
  font-family: var(--font-main);
  font-weight: 600;
  font-size: 15px;
  text-decoration: none;
  cursor: pointer;
  border: none;
  transition: all 0.25s ease;
}
.btn-sm {
  padding: 8px 18px;
  font-size: 14px;
  border-radius: 8px;
}
.btn-lg {
  padding: 14px 28px;
  font-size: 16px;
  border-radius: 14px;
}
.btn-block {
  width: 100%;
}

.btn-primary, .btn-emerald {
  background: linear-gradient(135deg, #10B981, #059669);
  color: #FFFFFF;
  box-shadow: 0 10px 25px -5px rgba(16, 185, 129, 0.4);
}
.btn-emerald:hover {
  transform: translateY(-2px);
  box-shadow: 0 15px 30px -5px rgba(16, 185, 129, 0.6);
}

.btn-glass {
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid var(--border-color);
  color: var(--text-main);
  backdrop-filter: blur(10px);
}
.btn-glass:hover {
  background: rgba(255, 255, 255, 0.14);
  border-color: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.btn-outline {
  background: transparent;
  border: 1px solid var(--border-color);
  color: var(--text-muted);
}
.btn-outline:hover {
  border-color: var(--emerald-500);
  color: var(--text-main);
  transform: translateY(-2px);
}

.btn-discord {
  background: #5865F2;
  color: #FFFFFF;
  box-shadow: 0 10px 25px -5px rgba(88, 101, 242, 0.4);
}
.btn-discord:hover {
  background: #4752C4;
  transform: translateY(-2px);
}

.btn-text-group {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  line-height: 1.2;
}
.btn-sub {
  font-size: 11px;
  font-weight: 500;
  opacity: 0.8;
}
.btn-main {
  font-size: 15px;
  font-weight: 700;
}

/* Navbar */
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 80px;
  display: flex;
  align-items: center;
  background: rgba(7, 11, 20, 0.8);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border-color);
  z-index: 100;
}
.nav-container {
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 0 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.nav-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
  color: var(--text-main);
}
.brand-icon {
  width: 38px;
  height: 38px;
}
.brand-text {
  font-size: 18px;
  font-weight: 800;
  letter-spacing: 0.5px;
}
.nav-links {
  display: flex;
  gap: 32px;
}
.nav-link {
  color: var(--text-muted);
  text-decoration: none;
  font-size: 15px;
  font-weight: 500;
  transition: color 0.2s ease;
}
.nav-link:hover {
  color: var(--emerald-400);
}

/* Hero Section */
.hero-section {
  padding: 160px 0 80px;
  position: relative;
}
.hero-grid {
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  gap: 50px;
  align-items: center;
}
.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  background: var(--emerald-dim);
  border: 1px solid rgba(16, 185, 129, 0.3);
  border-radius: 100px;
  margin-bottom: 24px;
}
.badge-dot {
  width: 8px;
  height: 8px;
  background: var(--emerald-400);
  border-radius: 50%;
  box-shadow: 0 0 10px var(--emerald-400);
}
.badge-text {
  font-size: 13px;
  font-weight: 600;
  color: var(--emerald-400);
}
.hero-title {
  font-size: 54px;
  line-height: 1.1;
  font-weight: 900;
  margin-bottom: 20px;
}
.hero-subtitle {
  font-size: 18px;
  color: var(--text-muted);
  max-width: 540px;
  margin-bottom: 36px;
}
.hero-cta-group {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 40px;
}
.hero-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  border-top: 1px solid var(--border-color);
  padding-top: 24px;
}
.stat-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  color: var(--text-muted);
}

/* Hero HUD Preview */
.hud-card {
  padding: 28px;
  border: 1px solid rgba(16, 185, 129, 0.25);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.6);
}
.hud-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.hud-status-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-radius: 8px;
  font-family: var(--font-main);
  font-weight: 700;
  font-size: 13px;
  letter-spacing: 0.5px;
}
.status-safe {
  background: var(--emerald-dim);
  border: 1px solid rgba(16, 185, 129, 0.4);
  color: var(--emerald-400);
}
.status-caution {
  background: var(--amber-dim);
  border: 1px solid rgba(245, 158, 11, 0.4);
  color: var(--amber-400);
}
.status-danger {
  background: rgba(244, 63, 94, 0.15);
  border: 1px solid rgba(244, 63, 94, 0.4);
  color: #FB7185;
}
.hud-clock {
  font-family: var(--font-main);
  font-weight: 600;
  font-size: 14px;
  color: var(--text-sub);
}
.prayer-label {
  font-size: 11px;
  letter-spacing: 1px;
  color: var(--text-sub);
  font-weight: 700;
}
.prayer-name {
  font-size: 28px;
  font-weight: 800;
  color: var(--text-main);
}
.prayer-time {
  font-size: 14px;
  color: var(--text-muted);
  margin-bottom: 24px;
}
.mini-timeline {
  margin-bottom: 24px;
}
.timeline-bar {
  height: 8px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 100px;
  position: relative;
  margin-bottom: 10px;
}
.timeline-fill {
  height: 100%;
  background: linear-gradient(90deg, #10B981, #06B6D4);
  border-radius: 100px;
}
.timeline-marker {
  position: absolute;
  top: -18px;
  transform: translateX(-50%);
}
.marker-label {
  font-size: 10px;
  background: #10B981;
  color: #000;
  font-weight: 800;
  padding: 2px 6px;
  border-radius: 4px;
}
.timeline-legend {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: var(--text-sub);
}
.hud-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 18px;
  border-top: 1px solid var(--border-color);
}
.hud-game-active {
  display: flex;
  align-items: center;
  gap: 12px;
}
.game-icon-sm {
  width: 28px;
  height: 28px;
}
.game-title {
  display: block;
  font-weight: 700;
  font-size: 14px;
}
.game-duration {
  font-size: 12px;
  color: var(--text-muted);
}
.hud-verdict {
  font-size: 13px;
  font-weight: 600;
}

/* Sections */
.section {
  padding: 100px 0;
  position: relative;
}
.section-tag {
  display: inline-block;
  font-family: var(--font-main);
  font-size: 12px;
  letter-spacing: 1.5px;
  font-weight: 700;
  color: var(--emerald-400);
  margin-bottom: 12px;
}
.section-title {
  font-size: 38px;
  font-weight: 800;
  margin-bottom: 14px;
}
.section-subtitle {
  font-size: 17px;
  color: var(--text-muted);
  max-width: 620px;
  margin: 0 auto 50px;
}

/* Interactive Calculator Box */
.calculator-box {
  padding: 40px;
}
.calc-grid {
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  gap: 40px;
  align-items: center;
}
.game-selector-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-top: 10px;
}
.game-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--border-color);
  border-radius: 10px;
  color: var(--text-muted);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.game-btn img {
  width: 18px;
  height: 18px;
}
.game-btn:hover {
  background: rgba(255, 255, 255, 0.08);
  color: var(--text-main);
}
.game-btn.active {
  background: var(--emerald-dim);
  border-color: var(--emerald-500);
  color: var(--emerald-400);
}
.form-group {
  margin-bottom: 24px;
}
.form-group label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-muted);
  margin-bottom: 8px;
}
.slider-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.range-slider {
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 5px;
  outline: none;
  accent-color: var(--emerald-500);
  margin-top: 8px;
  cursor: pointer;
}

/* Calculator Result Panel */
.calc-result-panel {
  padding: 30px;
  background: rgba(7, 11, 20, 0.7);
  border: 1px solid var(--border-color);
  border-radius: 16px;
}
.result-equation {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 0;
  margin: 20px 0;
  border-top: 1px solid var(--border-color);
  border-bottom: 1px solid var(--border-color);
}
.eq-item {
  text-align: center;
}
.eq-label {
  display: block;
  font-size: 11px;
  color: var(--text-sub);
  font-weight: 600;
}
.eq-val {
  font-size: 20px;
  font-weight: 700;
}
.eq-op {
  font-size: 18px;
  color: var(--text-sub);
}
.result-verdict-box h4 {
  font-size: 18px;
  margin-bottom: 6px;
}
.result-verdict-box p {
  font-size: 14px;
  color: var(--text-muted);
  margin-bottom: 20px;
}
.bar-track {
  height: 14px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 100px;
  display: flex;
  overflow: hidden;
  font-size: 9px;
  font-weight: 800;
  line-height: 14px;
  text-align: center;
  color: #000;
}
.bar-match { background: #06B6D4; transition: width 0.3s; }
.bar-buffer { background: #F59E0B; transition: width 0.3s; }
.bar-spare { background: #10B981; transition: width 0.3s; }

/* Features Grid */
.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}
.feature-card {
  padding: 32px;
}
.feature-icon-box {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  margin-bottom: 20px;
}
.bg-emerald-dim { background: var(--emerald-dim); }
.bg-cyan-dim { background: var(--cyan-dim); }
.bg-amber-dim { background: var(--amber-dim); }
.bg-purple-dim { background: var(--purple-dim); }
.feature-heading {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 10px;
}
.feature-desc {
  font-size: 14px;
  color: var(--text-muted);
  line-height: 1.6;
}

/* Downloads Grid */
.downloads-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 30px;
}
.download-card {
  padding: 36px;
  display: flex;
  flex-direction: column;
}
.popular-card {
  border-color: var(--emerald-500);
  box-shadow: 0 0 35px -10px rgba(16, 185, 129, 0.3);
  position: relative;
}
.popular-badge {
  position: absolute;
  top: -14px;
  left: 50%;
  transform: translateX(-50%);
  background: var(--emerald-500);
  color: #000;
  font-weight: 800;
  font-size: 12px;
  padding: 4px 14px;
  border-radius: 100px;
}
.card-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 18px;
}
.platform-icon {
  font-size: 38px;
}
.platform-name {
  font-size: 22px;
  font-weight: 800;
}
.platform-tag {
  font-size: 13px;
  color: var(--text-sub);
}
.platform-desc {
  font-size: 14px;
  color: var(--text-muted);
  margin-bottom: 24px;
  flex-grow: 1;
}
.platform-features {
  list-style: none;
  margin-bottom: 30px;
}
.platform-features li {
  font-size: 14px;
  color: var(--text-muted);
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.btn-stack {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.google-play-pill {
  padding: 8px 12px;
  border: 1px dashed var(--border-color);
  border-radius: 8px;
  font-size: 12px;
  color: var(--text-sub);
  text-align: center;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

/* Discord Section */
.discord-card {
  padding: 50px;
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: 50px;
  align-items: center;
  background: linear-gradient(135deg, rgba(14, 21, 38, 0.9), rgba(88, 101, 242, 0.12));
  border-color: rgba(88, 101, 242, 0.3);
}
.discord-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: #7289DA;
  font-weight: 700;
  font-size: 13px;
  margin-bottom: 12px;
}
.discord-title {
  font-size: 34px;
  font-weight: 800;
  margin-bottom: 16px;
}
.discord-desc {
  font-size: 16px;
  color: var(--text-muted);
  margin-bottom: 24px;
}
.discord-features-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 32px;
  font-size: 14px;
  color: var(--text-main);
}
.discord-features-list span {
  display: flex;
  align-items: center;
  gap: 10px;
}
.discord-preview-box {
  background: #2F3136;
  border-radius: 12px;
  padding: 20px;
}
.discord-msg-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 14px;
}
.discord-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
}
.bot-name { font-weight: 700; font-size: 14px; color: #FFF; }
.bot-tag { background: #5865F2; color: #FFF; font-size: 10px; font-weight: 800; padding: 2px 4px; border-radius: 4px; }
.msg-time { font-size: 11px; color: #72767D; margin-left: 6px; }
.discord-embed {
  display: flex;
  background: #202225;
  border-radius: 6px;
  overflow: hidden;
}
.embed-side-color {
  width: 4px;
  background: #10B981;
}
.embed-body {
  padding: 14px;
}
.embed-title { font-weight: 700; font-size: 14px; color: #10B981; margin-bottom: 6px; }
.embed-desc { font-size: 13px; color: #DCDDDE; margin-bottom: 10px; }
.embed-footer { font-size: 11px; color: #72767D; }

/* FAQ */
.faq-accordion {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.faq-item {
  padding: 20px 24px;
  cursor: pointer;
}
.faq-question {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 17px;
  font-weight: 700;
  list-style: none;
}
.faq-question::-webkit-details-marker {
  display: none;
}
.faq-icon {
  transition: transform 0.2s ease;
  font-size: 14px;
  color: var(--text-sub);
}
.faq-item[open] .faq-icon {
  transform: rotate(180deg);
  color: var(--emerald-400);
}
.faq-answer {
  margin-top: 14px;
  font-size: 15px;
  color: var(--text-muted);
  line-height: 1.6;
}

/* Footer */
.footer {
  padding: 80px 0 40px;
  border-top: 1px solid var(--border-color);
  margin-top: 60px;
}
.ayah-banner {
  padding: 30px;
  margin-bottom: 50px;
  border-color: rgba(245, 158, 11, 0.2);
}
.ayah-arabic {
  font-family: var(--font-arabic);
  font-size: 26px;
  color: #FBBF24;
  margin-bottom: 8px;
  direction: rtl;
}
.ayah-translation {
  font-size: 14px;
  color: var(--text-muted);
  font-style: italic;
}
.footer-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}
.footer-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 15px;
  font-weight: 700;
}
.footer-logo {
  width: 30px;
  height: 30px;
}
.footer-links {
  display: flex;
  gap: 24px;
}
.footer-links a {
  color: var(--text-muted);
  text-decoration: none;
  font-size: 14px;
}
.footer-links a:hover {
  color: var(--emerald-400);
}
.footer-copy {
  font-size: 13px;
  color: var(--text-sub);
  width: 100%;
  text-align: center;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

/* Responsive */
@media (max-width: 992px) {
  .hero-grid, .calc-grid, .discord-card {
    grid-template-columns: 1fr;
  }
  .features-grid, .downloads-grid {
    grid-template-columns: 1fr;
  }
  .game-selector-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .hero-title {
    font-size: 42px;
  }
  .nav-links {
    display: none;
  }
}
''');

  // 3. Write JavaScript
  print('⚡ Generating Interactive JavaScript...');
  File('$webDir\\js\\app.js').writeAsStringSync('''
// Live Clock
function updateClock() {
  const clockEl = document.getElementById('liveClock');
  if (!clockEl) return;
  const now = new Date();
  clockEl.textContent = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
}
setInterval(updateClock, 1000);
updateClock();

// Interactive Queue Calculator Logic
let selectedGameDuration = 35;
let selectedGameName = 'Valorant';

const timeRemainingInput = document.getElementById('timeRemainingInput');
const timeRemainingVal = document.getElementById('timeRemainingVal');
const bufferInput = document.getElementById('bufferInput');
const bufferVal = document.getElementById('bufferVal');

const calcMatchDuration = document.getElementById('calcMatchDuration');
const calcBufferDisplay = document.getElementById('calcBufferDisplay');
const calcRequiredTotal = document.getElementById('calcRequiredTotal');

const calcStatusBadge = document.getElementById('calcStatusBadge');
const calcStatusIcon = document.getElementById('calcStatusIcon');
const calcStatusTitle = document.getElementById('calcStatusTitle');
const calcVerdictHeadline = document.getElementById('calcVerdictHeadline');
const calcVerdictDesc = document.getElementById('calcVerdictDesc');

const barMatch = document.getElementById('barMatch');
const barBuffer = document.getElementById('barBuffer');
const barSpare = document.getElementById('barSpare');

function calculateRisk() {
  const timeRemaining = parseInt(timeRemainingInput.value, 10);
  const buffer = parseInt(bufferInput.value, 10);
  const matchMin = selectedGameDuration;
  const totalRequired = matchMin + buffer;
  const spareTime = timeRemaining - totalRequired;

  // Update text values
  timeRemainingVal.textContent = timeRemaining + ' min';
  bufferVal.textContent = buffer + ' min';
  calcMatchDuration.textContent = matchMin + 'm';
  calcBufferDisplay.textContent = buffer + 'm';
  calcRequiredTotal.textContent = totalRequired + 'm';

  // Status computation
  calcStatusBadge.className = 'result-badge';
  calcStatusIcon.className = 'fa-solid';

  if (timeRemaining >= totalRequired) {
    calcStatusBadge.classList.add('status-safe');
    calcStatusIcon.classList.add('fa-circle-check');
    calcStatusTitle.textContent = 'SAFE TO PLAY';
    calcVerdictHeadline.textContent = 'You have plenty of time!';
    calcVerdictDesc.textContent = `You will finish your match approximately \${spareTime} minutes before the Adhan call. Safe to start another \${selectedGameName} queue.`;
  } else if (timeRemaining >= matchMin) {
    calcStatusBadge.classList.add('status-caution');
    calcStatusIcon.classList.add('fa-triangle-exclamation');
    calcStatusTitle.textContent = 'CAUTION (BUFFER RISK)';
    calcVerdictHeadline.textContent = 'Close to prayer window!';
    calcVerdictDesc.textContent = `You will finish during your \${buffer}m safety buffer. If the match goes into overtime, you may delay your Salah.`;
  } else {
    calcStatusBadge.classList.add('status-danger');
    calcStatusIcon.classList.add('fa-circle-xmark');
    calcStatusTitle.textContent = 'TOO CLOSE TO PRAY';
    calcVerdictHeadline.textContent = 'Do not queue!';
    calcVerdictDesc.textContent = `A \${matchMin}m match will overlap into Salah by \${Math.abs(timeRemaining - matchMin)} minutes. Perform Wudu and pray first!`;
  }

  // Update visual bar
  const totalBarWidth = Math.max(timeRemaining, totalRequired);
  const matchPct = Math.min(100, Math.round((matchMin / totalBarWidth) * 100));
  const bufferPct = Math.min(100 - matchPct, Math.round((buffer / totalBarWidth) * 100));
  const sparePct = Math.max(0, 100 - matchPct - bufferPct);

  barMatch.style.width = matchPct + '%';
  barMatch.textContent = `Match (\${matchMin}m)`;
  barBuffer.style.width = bufferPct + '%';
  barBuffer.textContent = `Buffer (\${buffer}m)`;
  barSpare.style.width = sparePct + '%';
  barSpare.textContent = sparePct > 10 ? `Spare (\${Math.max(0, spareTime)}m)` : '';
}

// Game Selection buttons
const gameButtons = document.querySelectorAll('.game-btn');
gameButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    gameButtons.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    selectedGameDuration = parseInt(btn.dataset.min, 10);
    selectedGameName = btn.dataset.name;
    calculateRisk();
  });
});

timeRemainingInput.addEventListener('input', calculateRisk);
bufferInput.addEventListener('input', calculateRisk);
calculateRisk();
''');

  // 4. Write Discord Bot Architecture & Provisioner
  print('🤖 Generating Discord Bot & Server Architect...');
  
  // package.json
  File('$discordDir\\package.json').writeAsStringSync('''{
  "name": "pray-then-play-discord",
  "version": "2.0.0",
  "description": "Official Discord Automation, Server Architect & Salah Companion for Pray Then Play Community",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "deploy-commands": "node src/scripts/deploy-commands.js",
    "deploy-server": "node src/scripts/deploy-server.js"
  },
  "dependencies": {
    "discord.js": "^14.14.1",
    "dotenv": "^16.4.5"
  },
  "devDependencies": {
    "nodemon": "^3.1.0"
  }
}
''');

  // .env.example
  File('$discordDir\\.env.example').writeAsStringSync('''# Discord Bot Configuration
DISCORD_TOKEN=your_bot_token_here
CLIENT_ID=your_client_id_here
GUILD_ID=your_server_id_here
''');

  // README.md
  File('$discordDir\\README.md').writeAsStringSync('''# 🕌 PRAY THEN PLAY — DISCORD COMMUNITY & SERVER ARCHITECT

Official Discord automation, community management, and instant server architect for **Pray Then Play**.

---

## ⚡ Quick Start

### 1. Setup Environment
```bash
npm install
cp .env.example .env
```
Fill in your credentials from the [Discord Developer Portal](https://discord.com/developers/applications).

### 2. 1-Click Server Architect (Vibe Build)
Run the automated architect to construct the full community structure:
```bash
npm run deploy-server
```
**This script automatically provisions:**
- **Roles Hierarchy**: `👑 Emir // Founder`, `🛡️ Council // Staff`, `🤖 Automations // Bots`, `💎 VIP Supporter`, `💻 PC Gamers`, `📱 Mobile Gamers`, `🏆 Salah Streak Keepers`, and game roles.
- **Categories & Channels**:
  - `📜 INFORMATION & WELCOME` (`#rules`, `#announcements`, `#official-links`)
  - `🎭 ROLE SELECTION` (`#get-roles` with interactive buttons)
  - `💬 PRAY THEN PLAY HUB` (`#general-chat`, `#support`, `#feature-requests`, `#bug-reports`)
  - `🎮 GAMER LFG & SQUADS` (`#lfg-competitive`, `#clips`)
  - `🔊 VOICE LOUNGES` (`Duo`, `Trio`, `5v5 Squad`)

### 3. Register Slash Commands
```bash
npm run deploy-commands
```

### 4. Start Bot Runner
```bash
npm start
```
''');

  // src/config.js
  File('$discordDir\\src\\config.js').writeAsStringSync('''module.exports = {
  colors: {
    primary: 0x10B981,   // Emerald
    secondary: 0x06B6D4, // Cyan
    warning: 0xF59E0B,   // Amber
    danger: 0xF43F5E,    // Crimson
    dark: 0x0B1020       // Deep Obsidian
  },
  links: {
    website: 'https://praythenplay.com',
    github: 'https://github.com/TryOmar/pray-then-play',
    webApp: 'http://localhost:3000'
  },
  games: [
    'Valorant',
    'League of Legends',
    'Counter-Strike 2',
    'Fortnite',
    'Minecraft',
    'Dota 2',
    'Overwatch 2',
    'Rocket League'
  ]
};
''');

  // src/scripts/deploy-server.js
  File('$discordDir\\src\\scripts\\deploy-server.js').writeAsStringSync('''require('dotenv').config();
const { Client, GatewayIntentBits, PermissionsBitField, ChannelType, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
const config = require('../config');

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers]
});

client.once('ready', async () => {
  console.log(`[Architect] Logged in as \${client.user.tag}`);
  
  const guild = client.guilds.cache.get(process.env.GUILD_ID);
  if (!guild) {
    console.error('❌ Guild not found. Check GUILD_ID in .env');
    process.exit(1);
  }

  console.log(`🏗️ Provisioning Pray Then Play community in \${guild.name}...`);

  try {
    // 1. Create Roles
    console.log('👑 Creating Roles...');
    const rolesMap = {};
    const rolesToCreate = [
      { name: '👑 Emir // Founder', color: 0xF59E0B, hoist: true },
      { name: '🛡️ Council // Staff', color: 0x10B981, hoist: true },
      { name: '🤖 Automations // Bots', color: 0x06B6D4, hoist: true },
      { name: '💎 VIP Supporter', color: 0x8B5CF6, hoist: true },
      { name: '🏆 Salah Streak Keeper', color: 0x34D399, hoist: false },
      { name: '💻 PC Gamer', color: 0x38BDF8, hoist: false },
      { name: '📱 Mobile Gamer', color: 0x4ADE80, hoist: false },
      { name: '🌐 Web User', color: 0xFBBF24, hoist: false }
    ];

    for (const r of rolesToCreate) {
      let role = guild.roles.cache.find(x => x.name === r.name);
      if (!role) {
        role = await guild.roles.create({
          name: r.name,
          color: r.color,
          hoist: r.hoist,
          reason: 'Pray Then Play Server Architect'
        });
      }
      rolesMap[r.name] = role;
    }

    // 2. Create Categories & Channels
    console.log('📁 Creating Categories and Channels...');
    const categories = [
      {
        name: '📜 INFORMATION & WELCOME',
        channels: ['welcome-and-rules', 'announcements', 'official-links', 'get-roles']
      },
      {
        name: '💬 PRAY THEN PLAY HUB',
        channels: ['general-chat', 'setup-and-support', 'feature-requests', 'bug-reports']
      },
      {
        name: '🎮 GAMER LFG & SQUADS',
        channels: ['lfg-competitive', 'game-clips-and-setups']
      }
    ];

    for (const cat of categories) {
      let category = guild.channels.cache.find(c => c.name === cat.name && c.type === ChannelType.GuildCategory);
      if (!category) {
        category = await guild.channels.create({
          name: cat.name,
          type: ChannelType.GuildCategory
        });
      }

      for (const chName of cat.channels) {
        let channel = guild.channels.cache.find(c => c.name === chName && c.parentId === category.id);
        if (!channel) {
          channel = await guild.channels.create({
            name: chName,
            type: ChannelType.GuildText,
            parent: category.id
          });
        }
      }
    }

    console.log('✅ Server architecture deployed successfully!');
  } catch (err) {
    console.error('❌ Error provisioning server:', err);
  } finally {
    client.destroy();
  }
});

client.login(process.env.DISCORD_TOKEN);
''');

  // src/scripts/deploy-commands.js
  File('$discordDir\\src\\scripts\\deploy-commands.js').writeAsStringSync('''require('dotenv').config();
const { REST, Routes, SlashCommandBuilder } = require('discord.js');

const commands = [
  new SlashCommandBuilder()
    .setName('salah')
    .setDescription('Get current Islamic prayer times for your city')
    .addStringOption(option =>
      option.setName('city')
        .setDescription('City name (e.g. Cairo, London, New York)')
        .setRequired(false)
    ),
  new SlashCommandBuilder()
    .setName('queue')
    .setDescription('Calculate if it is safe to play a match before Salah')
    .addStringOption(option =>
      option.setName('game')
        .setDescription('Game title (e.g. Valorant, League, CS2)')
        .setRequired(true)
    )
    .addIntegerOption(option =>
      option.setName('duration')
        .setDescription('Estimated match duration in minutes')
        .setRequired(false)
    ),
  new SlashCommandBuilder()
    .setName('download')
    .setDescription('Get direct download links for Pray Then Play (Windows, Android, Web)'),
  new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Replies with Pong and bot latency')
].map(command => command.toJSON());

const rest = new REST({ version: '10' }).setToken(process.env.DISCORD_TOKEN);

(async () => {
  try {
    console.log('🔄 Registering slash commands with Discord REST API...');
    await rest.put(
      Routes.applicationGuildCommands(process.env.CLIENT_ID, process.env.GUILD_ID),
      { body: commands }
    );
    console.log('✅ Slash commands registered successfully!');
  } catch (error) {
    console.error('❌ Error registering slash commands:', error);
  }
})();
''');

  // src/index.js
  File('$discordDir\\src\\index.js').writeAsStringSync('''require('dotenv').config();
const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');
const config = require('./config');

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent
  ]
});

client.once('ready', () => {
  console.log(`🕌 Pray Then Play Bot is online as \${client.user.tag}`);
  client.user.setActivity('🕌 Salah Times • /queue to check');
});

client.on('interactionCreate', async interaction => {
  if (!interaction.isChatInputCommand()) return;

  const { commandName } = interaction;

  if (commandName === 'ping') {
    await interaction.reply({ content: `🏓 Pong! Latency: \${client.ws.ping}ms`, ephemeral: true });
  } else if (commandName === 'download') {
    const embed = new EmbedBuilder()
      .setColor(config.colors.primary)
      .setTitle('📥 Download Pray Then Play')
      .setDescription('Never miss Salah for a match again. Get the latest release across all platforms:')
      .addFields(
        { name: '🪟 Windows Setup (.exe)', value: '[Download v2.0.0](https://praythenplay.com/downloads/PrayThenPlay-Setup-v2.0.0-x64.exe) (15.3 MB)', inline: true },
        { name: '📱 Android APK', value: '[Download APK](https://praythenplay.com/downloads/PrayThenPlay-v2.0.0.apk) (66.2 MB)', inline: true },
        { name: '🌐 Web App', value: '[Launch Web App](http://localhost:3000)', inline: true }
      )
      .setFooter({ text: 'Pray Then Play • Community Edition' });

    await interaction.reply({ embeds: [embed] });
  }
});

client.login(process.env.DISCORD_TOKEN);
''');

  print('====================================================');
  print('🎉 PRAY THEN PLAY ECOSYSTEM GENERATED SUCCESSFULLY!');
  print('📁 Website: $webDir');
  print('📁 Discord: $discordDir');
  print('====================================================\n');
}
