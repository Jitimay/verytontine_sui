# Google OAuth Setup Guide for VeryTontine

This guide will help you configure Google OAuth authentication to fix the `ApiException: 10` error.

## Quick Fix (5 minutes)

Follow these steps to get authentication working immediately:

### Step 1: Get Your SHA-1 Fingerprint

Open a terminal and run:

**Linux/Mac:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

**Windows:**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr SHA1
```

Copy the SHA-1 fingerprint (format: `AA:BB:CC:DD:EE:...`)

### Step 2: Configure Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)

2. **Create or Select Project:**
   - Click on the project dropdown at the top
   - Create a new project named "VeryTontine" or select an existing one

3. **Enable Google Sign-In API:**
   - Go to: APIs & Services → Library
   - Search for "Google Sign-In API"
   - Click "Enable" (if not already enabled)

4. **Configure OAuth Consent Screen:**
   - Go to: APIs & Services → OAuth consent screen
   - Choose "External" user type (or "Internal" if you have a Google Workspace)
   - Fill in required fields:
     - App name: `VeryTontine`
     - User support email: [your email]
     - Developer contact: [your email]
   - Click "Save and Continue"
   - Skip the Scopes section (click "Save and Continue")
   - Skip Test users section (click "Save and Continue")

5. **Create OAuth Client ID:**
   - Go to: APIs & Services → Credentials
   - Click: "Create Credentials" → "OAuth client ID"
   - Application type: **Android**
   - Name: `VeryTontine Android Debug`
   - Package name: `com.verytontine.verytontine_flutter`
   - SHA-1 certificate fingerprint: [paste from Step 1]
   - Click "Create"

6. **Copy the Client ID:**
   - After creation, you'll see your Client ID
   - It looks like: `123456789-abcdefg.apps.googleusercontent.com`
   - **Copy this entire string**

### Step 3: Update Your Code

1. Open `verytontine_flutter/lib/config/oauth_config.dart`

2. Find this line:
   ```dart
   static const String debugAndroidClientId = 
       'YOUR_DEBUG_CLIENT_ID.apps.googleusercontent.com';
   ```

3. Replace `YOUR_DEBUG_CLIENT_ID.apps.googleusercontent.com` with your actual Client ID from Step 2.6

4. Save the file

### Step 4: Rebuild and Test

```bash
cd verytontine_flutter
flutter clean
flutter pub get
flutter run
```

The authentication should now work! 🎉

---

## Troubleshooting

### Error: "ApiException: 10" still appears

**Cause:** SHA-1 fingerprint mismatch or incorrect package name

**Solution:**
1. Verify the package name in Google Cloud Console matches exactly: `com.verytontine.verytontine_flutter`
2. Verify you copied the SHA-1 fingerprint correctly (no extra spaces)
3. Wait 5-10 minutes for Google's servers to update
4. Try `flutter clean` and rebuild

### Error: "Network error"

**Cause:** No internet connection or firewall blocking Google services

**Solution:**
1. Check your internet connection
2. Try on a different network
3. Disable VPN if using one

### Error: "Sign-in cancelled"

**Cause:** User cancelled the sign-in dialog

**Solution:** This is normal behavior - just try signing in again

### Error: "Configuration error"

**Cause:** Client ID not updated in oauth_config.dart

**Solution:** Make sure you updated the `debugAndroidClientId` in `oauth_config.dart`

---

## Production Setup

For production releases, you'll need to:

1. **Generate Release Keystore:**
   ```bash
   keytool -genkey -v -keystore ~/verytontine-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias verytontine
   ```

2. **Get Release SHA-1:**
   ```bash
   keytool -list -v -keystore ~/verytontine-release-key.jks -alias verytontine
   ```

3. **Create Production OAuth Client:**
   - Follow the same steps as above
   - Use the release SHA-1 fingerprint
   - Name it "VeryTontine Android Production"

4. **Update oauth_config.dart:**
   ```dart
   static const String prodAndroidClientId = 
       'YOUR_PROD_CLIENT_ID.apps.googleusercontent.com';
   ```

5. **Configure Signing in build.gradle.kts:**
   - Add release signing configuration
   - Reference your release keystore

6. **Build Release APK:**
   ```bash
   flutter build apk --release --dart-define=PRODUCTION=true
   ```

---

## Security Best Practices

1. **Never commit credentials to git:**
   - Add `oauth_config.dart` to `.gitignore` for production
   - Use environment variables or CI/CD secrets

2. **Protect your keystore:**
   - Store release keystore securely
   - Use strong passwords
   - Keep backups in a safe location

3. **Restrict API keys:**
   - In Google Cloud Console, restrict OAuth client to specific package name
   - Restrict to specific SHA-1 fingerprints
   - Monitor usage regularly

---

## Additional Resources

- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android/start)
- [OAuth 2.0 for Mobile Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
- [Flutter Google Sign-In Package](https://pub.dev/packages/google_sign_in)

---

## Need Help?

If you're still experiencing issues:

1. Check the console output for detailed error messages
2. Verify all steps were followed correctly
3. Wait 5-10 minutes after creating OAuth credentials (Google servers need time to propagate)
4. Try on a physical device instead of emulator
5. Review the full spec in `.kiro/specs/google-oauth-setup/`

---

**Current Status:** ✅ Code is ready - just needs OAuth Client ID configuration!
