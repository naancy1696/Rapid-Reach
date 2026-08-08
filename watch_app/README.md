# Rapid Reach - Wear OS Companion Application

## Module Overview
This is the **Module 3: Wear OS Companion Application** for the Rapid Reach project.

## Technology Stack
- **Language**: Kotlin
- **UI Framework**: Jetpack Compose for Wear OS
- **Min SDK**: API 30 (Wear OS 7.0)
- **Target SDK**: API 34 (Wear OS 11)
- **Build System**: Gradle with Kotlin DSL

## Project Structure
```
watch_app/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── kotlin/com/rapidreach/wearos/
│   │       │   └── MainActivity.kt
│   │       ├── res/
│   │       │   ├── values/
│   │       │   │   ├── strings.xml
│   │       │   │   ├── colors.xml
│   │       │   │   └── themes.xml
│   │       │   ├── drawable/
│   │       │   ├── layout/
│   │       │   └── xml/
│   │       └── AndroidManifest.xml
│   ├── build.gradle.kts
│   └── proguard-rules.pro
├── gradle/
│   └── wrapper/
│       └── gradle-wrapper.properties
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
└── .gitignore
```

## Current Status
**Foundation Phase**: Basic Wear OS app structure with Jetpack Compose UI framework.

### What's Included
- ✅ Gradle project setup with Wear OS dependencies
- ✅ MainActivity with basic Compose UI (Time display + app name)
- ✅ Android manifest with Wear OS permissions
- ✅ Resource files (colors, strings, themes)
- ✅ ProGuard rules for optimization

### What's NOT Included (Yet)
- ❌ Heart rate monitoring
- ❌ SpO₂ monitoring
- ❌ Accelerometer/Gyroscope integration
- ❌ Fall detection
- ❌ Inactivity detection
- ❌ Bluetooth connectivity
- ❌ Wear OS Data Layer
- ❌ Firebase integration
- ❌ Backend API integration
- ❌ SOS communication
- ❌ Emergency detection
- ❌ Background monitoring services

## Building the Project

### Prerequisites
- Android SDK (API 34)
- Android Build Tools (34.0.0 or later)
- Gradle 8.2 or later
- Kotlin 1.9.22 or later

### Build Commands
```bash
cd watch_app
./gradlew build                 # Build the project
./gradlew assembleDebug         # Build debug APK
./gradlew assembleRelease       # Build release APK
./gradlew connectedAndroidTest  # Run tests on connected device
./gradlew clean                 # Clean build files
```

## Development Notes
- This is an **independent Wear OS project** separate from the Flutter mobile app
- Uses **Jetpack Compose** for modern, declarative UI
- Designed for **round and square Wear OS devices** (API 30+)
- Currently contains **foundation UI only** (no sensors or connectivity)

## Next Steps
1. ✅ Verify project builds successfully (in progress)
2. Implement sensor integration (heart rate, SpO₂, accelerometer)
3. Add Wear OS Data Layer for mobile-watch communication
4. Implement health monitoring features
5. Add emergency detection and SOS functionality
6. Integrate with backend services

## References
- [Wear OS Documentation](https://developer.android.com/wear)
- [Jetpack Compose for Wear OS](https://developer.android.com/wear/compose)
- [Material Design for Wear OS](https://material.io/design/platform-guidance/android-wear.html)
