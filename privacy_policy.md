# Privacy Policy for Pray Then Play (PTP)

*Last updated: August 20, 2026*

**Pray Then Play** ("we", "our", or "us") is dedicated to protecting your privacy. This Privacy Policy explains our practices regarding data collection, usage, and disclosure when you use the **Pray Then Play** mobile application (the "App").

---

### 1. Zero Personal Data Collection
We believe in absolute user privacy. **Pray Then Play does NOT collect, store, transmit, sell, or share any personally identifiable information (PII) with third parties.** There are no user accounts, logins, advertising tracking networks, or third-party analytics SDKs embedded in the App.

---

### 2. Device Permissions and Usage

The App requests the following device permissions solely to provide core functionality locally on your device:

1. **Location (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`)**:
   - **Purpose**: Used strictly on your local device to calculate accurate astronomical prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha) and Qibla direction based on your coordinates.
   - **Data Handling**: Your GPS coordinates are processed entirely in-memory on your device and are never transmitted to external servers. You may also manually choose a city from the built-in database without granting location access.

2. **Notifications (`POST_NOTIFICATIONS`)**:
   - **Purpose**: Used to deliver timely prayer reminder alerts and Adhan notifications before and at prayer times.
   - **Data Handling**: Notifications are scheduled and triggered locally by your device's operating system.

3. **Exact Alarms (`SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`)**:
   - **Purpose**: Ensures prayer reminders fire precisely at the calculated prayer and buffer times even when the device is in battery-saving sleep mode.

4. **Boot Completed (`RECEIVE_BOOT_COMPLETED`)**:
   - **Purpose**: Re-schedules your daily prayer reminders automatically if you restart or reboot your device.

---

### 3. Local Storage
All your preferences (chosen gaming themes, calculation methods, safety buffer levels, logged prayer records, and custom game profiles) are stored locally in your device's private storage (using Android SharedPreferences / local sandbox). Clearing the App's storage or uninstalling the App permanently deletes this local data.

---

### 4. Children's Privacy
Our App does not collect any personal information from anyone, including children under the age of 13.

---

### 5. Changes to This Privacy Policy
We may update our Privacy Policy from time to time. Any changes will be reflected with an updated date at the top of this document.

---

### 6. Contact Us
If you have any questions or suggestions regarding this Privacy Policy, please contact us at:
- **Email**: `support@praythenplay.com`
- **Application ID**: `com.praythenplay.app`
