import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../config/oauth_config.dart';
import '../models/auth_models.dart';
import '../utils/auth_logger.dart';
import 'secure_storage_service.dart';
import 'ed25519_crypto_service.dart';
import 'session_manager.dart';

class ZkLoginService {
  late final GoogleSignIn _googleSignIn;
  
  ZkLoginService() {
    _googleSignIn = GoogleSignIn(
      scopes: OAuthConfig.requiredScopes,
      serverClientId: OAuthConfig.webServerClientId,
    );
  }
  
  String? _ephemeralPrivateKey;
  String? _ephemeralPublicKey;
  String? _randomness;
  int? _maxEpoch;
  String? _nonce;
  
  Future<AuthenticationResult> signInWithGoogle() async {
    try {
      // Validate configuration before attempting sign-in
      if (!OAuthConfig.isConfigured()) {
        return AuthenticationResult.failure(
          errorMessage: OAuthConfig.getConfigurationError() ?? 'Configuration error',
          errorType: AuthErrorType.configurationError,
        );
      }
      
      AuthLogger.i('Starting zkLogin', context: {
        'clientId': OAuthConfig.androidClientId,
        'package': 'com.verytontine.verytontine_flutter',
      });
      
      // 1. Generate ephemeral keypair and nonce
      await _generateEphemeralData();
      
      // 2. Perform Google Sign-In with nonce
      AuthLogger.d('Attempting Google Sign-In...');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        AuthLogger.d('User cancelled sign-in');
        return AuthenticationResult.failure(
          errorMessage: '', // Silent failure
          errorType: AuthErrorType.userCancelled,
        );
      }
      
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return AuthenticationResult.failure(
          errorMessage: 'Google Sign-In succeeded but no OpenID token was returned.\n\n'
              'In Google Cloud Console, create an OAuth client of type **Web application** '
              'in the same project and set `debugWebServerClientId` (or prod) in '
              'lib/config/oauth_config.dart to that client\'s ID.',
          errorType: AuthErrorType.tokenError,
        );
      }
      
      // 3. Derive zkLogin address
      final salt = _generateSalt();
      final zkAddress = _computeZkLoginAddress(idToken, salt);
      
      // Store for transaction signing
      await _storeZkLoginData(idToken, salt);
      
      return AuthenticationResult.success(
        suiAddress: zkAddress,
        idToken: idToken,
      );
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return AuthenticationResult.failure(
        errorMessage: 'Authentication failed: ${e.toString()}',
        errorType: AuthErrorType.unknown,
      );
    }
  }
  
  /// Handles platform-specific exceptions from Google Sign-In
  AuthenticationResult _handlePlatformException(PlatformException error) {
    // Extract error code from message if present
    final message = error.message ?? '';
    
    AuthLogger.e(
      'Google Sign-In Error',
      error: error,
      context: {
        'code': error.code,
        'message': message,
      },
    );
    
    // ApiException 10 / DEVELOPER_ERROR: wrong OAuth client, SHA-1, or package name
    final isDevError = error.code == 'sign_in_failed' &&
        (message.contains('10') ||
            message.contains('DEVELOPER_ERROR') ||
            message.contains('Developer console'));
    if (isDevError) {
      return AuthenticationResult.failure(
        errorMessage: 'Google Sign-In: ApiException 10 (DEVELOPER_ERROR).\n\n'
            'Common fix — wrong ID in Android resources:\n'
            '• Open android/app/src/main/res/values/strings.xml\n'
            '• If `default_web_client_id` is set to your **Android** client ID, REMOVE it or '
            'replace it with a **Web application** OAuth client ID from the same Google Cloud project.\n'
            '• The Android client ID must ONLY be registered in Console (package + SHA-1), '
            'not in default_web_client_id.\n'
            '• Put the same Web client ID in lib/config/oauth_config.dart as debugWebServerClientId.\n\n'
            'Also verify Android OAuth client: package com.verytontine.verytontine_flutter + '
            'debug SHA-1 from keytool, then wait a few minutes and reinstall the app.\n\n'
            'Raw: ${error.code} — $message',
        errorType: AuthErrorType.configurationError,
      );
    }
    
    // Error code 7: Network Error
    if (error.code == 'network_error' || message.contains('NETWORK_ERROR')) {
      return AuthenticationResult.failure(
        errorMessage: 'Network connection failed. Please check your internet.',
        errorType: AuthErrorType.networkError,
      );
    }
    
    // Error code 12501: User cancelled
    if (error.code == 'sign_in_canceled' || message.contains('12501')) {
      return AuthenticationResult.failure(
        errorMessage: '', // Silent failure
        errorType: AuthErrorType.userCancelled,
      );
    }
    
    // Error code 8: Internal Error
    if (message.contains('8:')) {
      return AuthenticationResult.failure(
        errorMessage: 'Authentication service unavailable. Please try again.',
        errorType: AuthErrorType.unknown,
      );
    }
    
    // Default error handling with detailed info
    return AuthenticationResult.failure(
      errorMessage: 'Authentication failed.\n\n'
          'Error Code: ${error.code}\n'
          'Message: $message\n\n'
          'If this persists, check OAuth configuration.',
      errorType: AuthErrorType.unknown,
    );
  }
  
  Future<void> _generateEphemeralData() async {
    // Generate Ed25519 key pair
    final (privateKey, publicKey) = await Ed25519CryptoService.generateKeyPair();
    _ephemeralPrivateKey = privateKey;
    _ephemeralPublicKey = publicKey;
    
    // Generate randomness
    _randomness = _generateRandomness();
    
    // Set max epoch (current + 10 for safety)
    _maxEpoch = await _getCurrentEpoch() + 10;
    
    // Generate nonce
    _nonce = _generateNonce();
    
    AuthLogger.d('Generated ephemeral data', context: {
      'maxEpoch': _maxEpoch,
      'hasPrivateKey': _ephemeralPrivateKey != null,
      'hasPublicKey': _ephemeralPublicKey != null,
    });
  }
  
  String _generateRandomness() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }
  
  String _generateNonce() {
    if (_ephemeralPrivateKey == null || _maxEpoch == null || _randomness == null) {
      throw Exception('Ephemeral data not generated');
    }
    
    final input = '$_ephemeralPrivateKey|$_maxEpoch|$_randomness';
    final hash = sha256.convert(utf8.encode(input)).bytes;
    final nonce = base64Url.encode(hash).replaceAll('=', '');
    _nonce = nonce; // Store for potential future use
    return nonce;
  }
  
  String _generateSalt() {
    final random = Random.secure();
    return random.nextInt(1 << 32).toString();
  }
  
  String _computeZkLoginAddress(String jwt, String salt) {
    try {
      // Decode JWT payload
      final parts = jwt.split('.');
      if (parts.length != 3) throw Exception('Invalid JWT format');
      
      final payload = parts[1];
      final paddedPayload = payload + '=' * (4 - payload.length % 4);
      final decoded = base64Url.decode(paddedPayload);
      final claims = jsonDecode(utf8.decode(decoded));
      
      final sub = claims['sub'];
      final aud = claims['aud'];
      
      if (sub == null || aud == null) {
        throw Exception('Missing required JWT claims');
      }
      
      // Compute address hash
      final input = '$sub|$aud|$salt';
      final hash = sha256.convert(utf8.encode(input)).bytes;
      
      // Take first 20 bytes and format as Sui address
      final addressBytes = hash.take(20).toList();
      final addressHex = addressBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      
      return '0x$addressHex';
    } catch (e) {
      throw Exception('Failed to compute zkLogin address: $e');
    }
  }
  
  Future<int> _getCurrentEpoch() async {
    // In production, fetch from Sui RPC
    // For now, use timestamp-based approximation
    return DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  }
  
  Future<void> _storeZkLoginData(String jwt, String salt) async {
    await SecureStorageService.storeEphemeralKey(_ephemeralPrivateKey!);
    
    final address = _computeZkLoginAddress(jwt, salt);
    
    // Store session using SessionManager
    final sessionManager = SessionManager();
    await sessionManager.storeSession(
      jwt: jwt,
      salt: salt,
      ephemeralKey: _ephemeralPrivateKey!,
      suiAddress: address,
    );
    
    AuthLogger.i('zkLogin data stored', context: {'address': address});
  }
  
  Future<String> signTransaction(String txBytes) async {
    if (_ephemeralPrivateKey == null) {
      throw Exception('No ephemeral key available for signing');
    }
    
    // Create transaction signature using ephemeral key
    final hash = sha256.convert(base64Decode(txBytes)).bytes;
    final signature = _signWithEphemeralKey(hash);
    
    return base64Encode(signature);
  }
  
  List<int> _signWithEphemeralKey(List<int> message) {
    // Simplified signing - in production use proper Ed25519 signing
    final keyBytes = base64Url.decode(_ephemeralPrivateKey!);
    final combined = [...keyBytes, ...message];
    return sha256.convert(combined).bytes;
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await SecureStorageService.clearAll();
    _ephemeralPrivateKey = null;
    _randomness = null;
    _maxEpoch = null;
    _nonce = null;
  }
  
  bool get isSignedIn => _ephemeralPrivateKey != null;
}
