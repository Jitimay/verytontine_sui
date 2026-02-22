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
- ✅ Sui Move smart contracts (Hardened & Tested)
- ✅ zkLogin Authentication (Logic & UI)
- 🔄 Full On-Chain Integration (Currently Mocked in BLoCs)

## Core Features
1. **Savings Circles**: Permissioned groups for periodic contributions.
2. **Automated Vault**: Securely manages pool funds and determines the next beneficiary.
3. **zkLogin**: Seamless seedless onboarding using Google/Apple OIDC.
4. **Reputation System**: Dynamic trust scores based on payment history.

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
