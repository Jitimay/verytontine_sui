import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sui/sui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class ZkLoginService {
  static const String _googleClientId = '1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com';
  static const String _redirectUri = 'com.verytontine.app:/oauth2redirect';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: _googleClientId);
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  
  late Ed25519Keypair _ephemeralKeypair;
  late String _randomness;
  late int _maxEpoch;
  
  Future<String> signInWithGoogle() async {
    _ephemeralKeypair = Ed25519Keypair.generate();
    _randomness = _generateRandomness();
    _maxEpoch = await _getCurrentEpoch() + 10;
    
    final nonce = _generateNonce(_ephemeralKeypair.getPublicKey(), _maxEpoch, _randomness);
    
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        _googleClientId,
        _redirectUri,
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
          tokenEndpoint: 'https://oauth2.googleapis.com/token',
        ),
        additionalParameters: {'nonce': nonce},
        scopes: ['openid', 'email'],
      ),
    );
    
    if (result?.idToken != null) {
      return await _processZkLogin(result!.idToken!);
    }
    throw Exception('Google sign-in failed');
  }
  
  Future<String> _processZkLogin(String jwt) async {
    final salt = _generateSalt();
    final zkAddress = _computeZkLoginAddress(jwt, salt);
    
    // Store ephemeral keypair and other data for transaction signing
    return zkAddress;
  }
  
  String _generateRandomness() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }
  
  String _generateNonce(Ed25519PublicKey publicKey, int maxEpoch, String randomness) {
    final pubKeyBytes = publicKey.toRawBytes();
    final input = '${base64Url.encode(pubKeyBytes)}|$maxEpoch|$randomness';
    final hash = sha256.convert(utf8.encode(input)).bytes;
    return base64Url.encode(hash).replaceAll('=', '');
  }
  
  String _generateSalt() {
    final random = Random.secure();
    return random.nextInt(1 << 32).toString();
  }
  
  String _computeZkLoginAddress(String jwt, String salt) {
    final decoded = base64Url.decode(jwt.split('.')[1] + '==');
    final payload = jsonDecode(utf8.decode(decoded));
    final sub = payload['sub'];
    final aud = payload['aud'];
    
    // Simplified address computation - in production use Sui SDK
    final input = '$sub|$aud|$salt';
    final hash = sha256.convert(utf8.encode(input)).bytes;
    return '0x${hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join().substring(0, 40)}';
  }
  
  Future<int> _getCurrentEpoch() async {
    // In production, fetch from Sui RPC
    return DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  }
}
