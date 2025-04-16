# Guide Genie

A Flutter-based mobile app for gamers to quickly access tier lists, loadouts, and strategies for popular games.

## Overview

Guide Genie is a cross-platform mobile application designed for gamers who want quick and easy access to the latest meta information, strategies, tier lists, and loadouts for their favorite games. The app focuses on providing a centralized hub for game guides across multiple popular titles including Fortnite, League of Legends, Valorant, Street Fighter, Call of Duty, Warzone, and Marvel Rivals.

## Features

- **Game Guides**: Access comprehensive guides for popular games
- **Tier Lists**: View up-to-date tier lists for characters, weapons, and more
- **Loadout Recommendations**: Discover optimal loadouts and builds
- **Strategy Guides**: Learn advanced strategies from experienced players
- **User Contributions**: Create and share your own guides with the community
- **Favorites**: Save your preferred guides for quick access
- **Dark Mode**: Toggle between light and dark themes for comfortable viewing

## Supported Games

- Fortnite
- League of Legends
- Valorant
- Street Fighter
- Call of Duty
- Warzone
- Marvel Rivals

## Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Storage**: Shared Preferences for local storage
- **HTTP Client**: HTTP package for API requests
- **Authentication**: JWT-based authentication

## Project Structure

```
lib/
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # API and storage services
├── utils/            # Utility functions and constants
├── widgets/          # Reusable UI components
└── main.dart         # Application entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- iOS simulator or Android emulator (for testing)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/guide_genie.git
   ```

2. Navigate to the project directory:
   ```
   cd guide_genie
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Feel free to open issues and pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
