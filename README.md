# Plant Tracker

A Flutter application for tracking plant growth, watering schedules, and creating visual progress montages.

## Overview

Plant Tracker is a gardening journal that helps you monitor your plants over time. Add plants, record watering and growth measurements, take photos, view growth charts, and create time-lapse GIFs of your plant's progress.

## Features

### Plant Management
- **Add plants** with name, planting date, optional notes, and initial height
- **Edit plant details** including name, notes, and initial growth record
- **Delete plants** (cascades to remove associated growth records, photos, and watering history)
- **View all plants** in a card-based list on the home screen

### Watering Tracking
- Mark plants as watered with a single tap
- Visual indicator shows whether a plant has been watered today
- Tap again to undo a watering record for the current day
- Watering history persists in the local database

### Growth Records
- Add growth measurements (height) for any plant
- Records are stored with the current date
- If a record already exists for today, it gets updated instead of duplicated
- Supports both centimeters and inches (configured in Settings)
- Initial growth record created automatically when adding a new plant

### Photo Management
- Take photos using the device camera or select from gallery
- Photos are saved to app-specific storage and optionally to the system gallery
- Each photo is timestamped and associated with a specific plant
- View photos in the Montage Maker

### Growth Graphs
- Select a plant from a dropdown to view its growth history
- Line chart visualization using fl_chart
- X-axis shows dates, Y-axis shows height
- Toggle between CM and Inches in Settings
- Displays average growth calculation
- Area fill under the line for visual clarity

### Montage Maker
- Select a plant and create an animated slideshow of its photos
- Adjustable frame duration (0.5 to 1.0 seconds)
- Export the slideshow as a GIF with date labels on each frame
- GIFs are saved to the device gallery
- Share the generated GIF via system share sheet

### Settings
- **Measurement Unit**: Choose between CM and Inches (affects input and graph display)
- **Notifications**: Enable/disable daily watering reminders
- **Reminder Time**: Set the hour and minute for the daily notification
- **Appearance**: Choose Light, Dark, or System default theme
- **Remove Ads**: One-time in-app purchase to disable banner and interstitial ads

### Advertising & Monetization
- Banner ad displayed at the bottom of the main navigation (test ad unit IDs used)
- Interstitial ads shown periodically (every 90 seconds) when ads are not removed
- In-app purchase to permanently remove all ads
- Purchase restoration supported

### Data Persistence
- All data stored locally using SQLite (sqflite)
- Database file: `PlantsDatabase.db`
- Foreign key constraints with cascade delete
- Settings persisted via SharedPreferences

## Architecture

### Models
| Model | Table | Fields |
|-------|-------|--------|
| `Plant` | `plants` | id, name, planted_date, notes |
| `GrowthRecord` | `growth` | id, plantId, date, height |
| `Photo` | `photos` | id, plantId, imagePath, takenAt |
| `Wateringrecord` | `wateringrecord` | id, plantId, wateredAt |

### Services
- **DatabaseService**: Singleton managing all CRUD operations for the four tables
- **NotificationService**: Handles local notification scheduling and display using flutter_local_notifications with timezone support
- **AdService**: Manages Google Mobile Ads (banner + interstitial) with test ad unit IDs
- **IapService**: Handles in-app purchase flow for removing ads via in_app_purchase

### Pages
- `HomePage` - Main plant list with action icons for each plant
- `AddPlantPage` - Form to create a new plant with initial growth record
- `EditPlant` - Modify plant name, notes, and initial height
- `AddNewGrowthRecord` - Add or update today's growth measurement
- `CameraPage` - Capture or select photos for a plant
- `GraphPage` - Growth visualization with chart
- `MontagePlantPicturePage` - Slideshow viewer and GIF creator
- `SettingsPage` - App preferences and IAP

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter` | Core framework |
| `google_mobile_ads` | AdMob integration |
| `in_app_purchase` | In-app purchases |
| `cupertino_icons` | iOS-style icons |
| `google_fonts` | Quicksand and Baloo 2 fonts |
| `sqflite` | Local SQLite database |
| `date_field` | Date picker form field |
| `fl_chart` | Line chart for growth graphs |
| `flutter_local_notifications` | Local notifications |
| `timezone` | Timezone handling for scheduled notifications |
| `flutter_timezone` | Get device timezone |
| `image_picker` | Camera and gallery access |
| `path_provider` | App document directory access |
| `image` | GIF encoding and image manipulation |
| `gallery_saver_plus` | Save images/GIFs to system gallery |
| `shared_preferences` | Persistent key-value settings |
| `share_plus` | System share sheet |
| `flutter_launcher_icons` | App icon generation |

## Getting Started

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart SDK (included with Flutter)
- Android Studio / VS Code with Flutter plugin
- iOS development requires Xcode and macOS

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd plant_tracker

# Install dependencies
flutter pub get

# Generate launcher icons (if needed)
flutter pub run flutter_launcher_icons:main

# Run the app
flutter run
```

### Platform Configuration

**Android**: 
- Minimum SDK version configured in `android/app/build.gradle.kts`
- Keystore configuration in `android/key.properties` (for release builds)
- Test ad unit IDs are used; replace with production IDs before publishing

**iOS**:
- Configured in `ios/Runner/Info.plist`
- App icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**Web**:
- Entry point: `web/index.html`
- Manifest: `web/manifest.json`
- Icons in `web/icons/`

## Database Schema

```sql
CREATE TABLE plants (
    _id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    planted_date TEXT NOT NULL,
    notes TEXT
);

CREATE TABLE growth (
    _id INTEGER PRIMARY KEY AUTOINCREMENT,
    plantid INTEGER NOT NULL,
    date TEXT NOT NULL,
    height REAL NOT NULL,
    FOREIGN KEY (plantid) REFERENCES plants(_id) ON DELETE CASCADE
);

CREATE TABLE photos (
    _id INTEGER PRIMARY KEY AUTOINCREMENT,
    plantId INTEGER NOT NULL,
    imagePath TEXT NOT NULL,
    takenAt TEXT NOT NULL,
    FOREIGN KEY (plantId) REFERENCES plants(_id) ON DELETE CASCADE
);

CREATE TABLE wateringrecord (
    _id INTEGER PRIMARY KEY AUTOINCREMENT,
    plantId INTEGER NOT NULL,
    wateredAt TEXT NOT NULL,
    FOREIGN KEY (plantId) REFERENCES plants(_id) ON DELETE CASCADE
);
```

## Theming

The app uses Material 3 with two custom color palettes:

**Light Theme (Mauve Dust set)**
- Primary: Forest Frolic (#77A39A)
- Secondary: Mauve Dust (#CB96BA)
- Surface: Venus Flower (#E0E4E7)
- Background: #FBF9F6

**Dark Theme (Lily Pond set)**
- Primary: Moss Green (#839958)
- Secondary: Rosy Brown (#D3968C)
- Surface: Dark Green (#0A3323)
- Background: #0A3323

Typography uses Google Fonts: Quicksand for body text, Baloo 2 for headings.

## Notification System

- Uses `flutter_local_notifications` with Android platform
- Daily scheduled notifications at user-configured time
- Timezone-aware scheduling via `timezone` and `flutter_timezone` packages
- Channel: "Default Channel" with high importance/priority
- Notifications can be enabled/disabled in Settings

## In-App Purchase

- Product ID: `remove_ads`
- Non-consumable purchase
- Handled via `in_app_purchase` package
- On successful purchase/restore: `AdService.setAdsRemoved(true)`
- Purchase state persisted in SharedPreferences

## Known Limitations

- Test ad unit IDs are used; production deployment requires AdMob account and real ad unit IDs
- In-app purchase product must be configured in App Store Connect / Google Play Console
- Notification permissions must be granted by user on first run
- Camera and storage permissions required for photo features
- GIF creation uses isolate computation for performance

## License

See LICENSE file for details.