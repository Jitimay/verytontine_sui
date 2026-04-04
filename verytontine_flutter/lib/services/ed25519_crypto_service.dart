import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;

class Ed25519CryptoService {
  static Future<(String, String)> generateKeyPair() async {
    final random = Random.secure();
    final seed = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      seed[i] = random.nextInt(256);
    }
    
    final keyPair = ed25519.newKeyFromSeed(seed);
    
    final privateKeyEncoded = base64Url.encode(seed).replaceAll('=', '');
    final publicKeyEncoded = base64Url.encode(keyPair.bytes).replaceAll('=', '');
    
    return (privateKeyEncoded, publicKeyEncoded);
  }
  
  static Future<String> sign(List<int> message, String privateKey) async {
    if (message.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }
    
    final privateKeyBytes = _decodeBase64Url(privateKey);
    if (privateKeyBytes.length != 32) {
      throw FormatException('Invalid private key length');
    }
    
    final privKey = ed25519.PrivateKey(Uint8List.fromList(privateKeyBytes));
    final signature = ed25519.sign(privKey, Uint8List.fromList(message));
    
    return base64.encode(signature);
  }
  
  static Future<bool> verify(List<int> message, String signature, String publicKey) async {
    try {
      final publicKeyBytes = _decodeBase64Url(publicKey);
      final signatureBytes = base64.decode(signature);
      
      final pubKey = ed25519.PublicKey(Uint8List.fromList(publicKeyBytes));
      
      return ed25519.verify(pubKey, Uint8List.fromList(message), Uint8List.fromList(signatureBytes));
    } catch (e) {
      return false;
    }
  }
  
  /// Validates that a key is a valid Ed25519 private key
  /// 
  /// Checks:
  /// - Key is not empty
  /// - Key is valid base64url
  /// - Decoded key is exactly 32 bytes
  /// 
  /// Returns: true if valid, false otherwise
  /// 
  /// Example:
  /// ```dart
  /// if (Ed25519CryptoService.isValidPrivateKey(key)) {
  ///   // Use the key
  /// }
  /// ```
  static bool isValidPrivateKey(String key) {
    if (key.isEmpty) {
      return false;
    }
    
    try {
      final decoded = _decodeBase64Url(key);
      // Ed25519 private keys are exactly 32 bytes
      return decoded.length == 32;
    } catch (e) {
      return false;
    }
  }
  
  /// Validates that a key is a valid Ed25519 public key
  /// 
  /// Checks:
  /// - Key is not empty
  /// - Key is valid base64url
  /// - Decoded key is exactly 32 bytes
  /// 
  /// Returns: true if valid, false otherwise
  static bool isValidPublicKey(String key) {
    if (key.isEmpty) {
      return false;
    }
    
    try {
      final decoded = _decodeBase64Url(key);
      // Ed25519 public keys are exactly 32 bytes
      return decoded.length == 32;
    } catch (e) {
      return false;
    }
  }
  
  /// Helper method to decode base64url strings
  /// 
  /// Handles both padded and unpadded base64url strings
  static List<int> _decodeBase64Url(String encoded) {
    // Add padding if needed
    var padded = encoded;
    while (padded.length % 4 != 0) {
      padded += '=';
    }
    
    return base64Url.decode(padded);
  }
}
