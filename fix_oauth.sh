#!/bin/bash

# VeryTontine OAuth Configuration Fix Script

echo "🔧 VeryTontine OAuth Configuration Helper"
echo "=========================================="
echo ""

# Get SHA-1 fingerprint
echo "📱 Current Debug SHA-1 Fingerprint:"
SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | cut -d' ' -f3)
echo "   $SHA1"
echo ""

# Package name
echo "📦 Package Name:"
echo "   com.verytontine.verytontine_flutter"
echo ""

# Client ID
echo "🔑 Current OAuth Client ID:"
echo "   427498483720-tdul9p1mvk4ilsaars981m4r553vjivn.apps.googleusercontent.com"
echo ""

echo "🚀 To Fix Authentication Error:"
echo "================================"
echo "1. Go to: https://console.cloud.google.com/apis/credentials"
echo "2. Find your OAuth client ID (or create new Android client)"
echo "3. Add this SHA-1 fingerprint: $SHA1"
echo "4. Ensure package name is: com.verytontine.verytontine_flutter"
echo "5. Save changes in Google Cloud Console"
echo ""

echo "✅ After updating Google Cloud Console:"
echo "   cd verytontine_flutter"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"
echo ""

echo "🔍 If you need a new OAuth client ID:"
echo "   1. Create OAuth client ID → Android"
echo "   2. Package: com.verytontine.verytontine_flutter"
echo "   3. SHA-1: $SHA1"
echo "   4. Update lib/config/oauth_config.dart with new client ID"
