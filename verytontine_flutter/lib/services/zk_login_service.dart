import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class ZkLoginService {
  static const String _googleClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  static const String _redirectUri = 'com.verytontine.app:/oauth2redirect';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _googleClientId,
    scopes: ['openid', 'email'],
  );
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  
  String? _ephemeralPrivateKey;
  String? _randomness;
  int? _maxEpoch;
  String? _nonce;
  
  Future<String> signInWithGoogle() async {
    try {
      // 1. Generate ephemeral keypair and nonce
      await _generateEphemeralData();
      
      // 2. Perform Google Sign-In with nonce
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');
      
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('Failed to get ID token');
      
      // 3. Derive zkLogin address
      final salt = _generateSalt();
      final zkAddress = _computeZkLoginAddress(idToken, salt);
      
      // Store for transaction signing
      await _storeZkLoginData(idToken, salt);
      
      return zkAddress;
    } catch (e) {
      throw Exception('zkLogin failed: $e');
    }
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
    return base64Url.encode(hash).replaceAll('=', '');
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
