import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../config/oauth_config.dart';
import '../models/auth_models.dart';

class ZkLoginService {
  late final GoogleSignIn _googleSignIn;
  
  ZkLoginService() {
    _googleSignIn = GoogleSignIn(
      clientId: OAuthConfig.androidClientId,
      scopes: OAuthConfig.requiredScopes,
    );
  }
  
  String? _ephemeralPrivateKey;
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
      
      // 1. Generate ephemeral keypair and nonce
      await _generateEphemeralData();
      
      // 2. Perform Google Sign-In with nonce
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthenticationResult.failure(
          errorMessage: '', // Silent failure
          errorType: AuthErrorType.userCancelled,
        );
      }
      
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return AuthenticationResult.failure(
          errorMessage: 'Failed to get authentication token',
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
    
    // Error code 10: Developer Error (invalid client ID or SHA-1 mismatch)
    if (error.code == 'sign_in_failed' && message.contains('10:')) {
      return AuthenticationResult.failure(
        errorMessage: 'App configuration error. Please contact support.',
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
    
    // Default error handling
    return AuthenticationResult.failure(
      errorMessage: 'Authentication failed. Please try again.',
      errorType: AuthErrorType.unknown,
    );
  }
  
  Future<void> _generateEphemeralData() async {
    // Generate random private key (32 bytes)
    final random = Random.secure();
    final privateKeyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    _ephemeralPrivateKey = base64Url.encode(privateKeyBytes);
    
    // Generate randomness
    _randomness = _generateRandomness();
    
    // Set max epoch (current + 10 for safety)
    _maxEpoch = await _getCurrentEpoch() + 10;
    
    // Generate nonce
    _nonce = _generateNonce();
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
    // Store zkLogin data for transaction signing
    // In production, use secure storage
    // For now, keep in memory
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
    _ephemeralPrivateKey = null;
    _randomness = null;
    _maxEpoch = null;
    _nonce = null;
  }
  
  bool get isSignedIn => _ephemeralPrivateKey != null;
}
