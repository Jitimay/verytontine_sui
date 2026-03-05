# Quick Start: Fix Authentication Error

## The Problem
You're getting: `ApiException: 10` - This means Google OAuth is not configured.

## The Solution (5 minutes)

### 1. Get SHA-1 Fingerprint
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```
**Copy the SHA-1 value** (looks like: `AA:BB:CC:DD:...`)

### 2. Create OAuth Client
1. Go to: https://console.cloud.google.com/apis/credentials
2. Click "Create Credentials" → "OAuth client ID"
3. Choose "Android"
4. Package name: `com.verytontine.verytontine_flutter`
5. SHA-1: [paste from step 1]
6. Click "Create"
7. **Copy the Client ID** (ends with `.apps.googleusercontent.com`)

### 3. Update Configuration
Edit: `verytontine_flutter/lib/config/oauth_config.dart`

Find line 29:
```dart
static const String debugAndroidClientId = 
    'YOUR_DEBUG_CLIENT_ID.apps.googleusercontent.com';
```

Replace with your Client ID from step 2.

### 4. Test
```bash
cd verytontine_flutter
flutter clean
flutter pub get
flutter run
```

## Done! 🎉
Authentication should now work. If you still have issues, see `GOOGLE_OAUTH_SETUP.md` for detailed troubleshooting.
