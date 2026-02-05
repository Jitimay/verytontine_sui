# VeryTontine (Sui Move + Flutter)

VeryTontine is a community savings (tontine / ikirimba) protocol built on Sui with a Flutter mobile app.

## Project Structure
```
verytontine_sui/
├── sources/           # Sui Move smart contracts
├── tests/            # Move unit tests
├── verytontine_flutter/  # Flutter mobile app
├── Move.toml         # Move package config
└── README.md
```

## Goal
Enable trusted groups and diaspora communities to contribute funds transparently
using smart contracts with a mobile-first interface.

## MVP Scope (Mission 1)
- ✅ Flutter app with black theme UI
- ✅ BLoC state management
- 🔄 Sui Move smart contracts
- 🔄 Integration between Flutter and Sui

## Modules
- **`circle.move`**: Handles savings groups, membership, and rotation.
- **`vault.move`**: Manages the multi-user digital vault and payouts.
- **`trust_score.move`**: Tracks user reputation for financial history.

## Building and Testing

### Sui Move Contracts
```bash
# Build the Move package
sui move build

# Run Move unit tests
sui move test
```

### Flutter App
```bash
# Navigate to Flutter app
cd verytontine_flutter

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Tech Stack
- **Backend**: Sui blockchain (Move 2024 Edition)
- **Frontend**: Flutter with BLoC state management
- **Theme**: Dark/Black UI with green accents
