import 'dart:convert';
import 'package:flutter/services.dart';
import './auth_logger.dart';

class OAuthConfigLoader {
  static Future<String> loadClientIdFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/client_secret_427498483720-tdul9p1mvk4ilsaars981m4r553vjivn.apps.googleusercontent.com.json');
      final jsonData = jsonDecode(jsonString);
      
      // Extract client_id from JSON structure
      return jsonData['installed']['client_id'] ?? '';
    } catch (e) {
      AuthLogger.e('Error loading OAuth config', error: e);
      return '';
    }
  }
}
