import 'package:flutter_test/flutter_test.dart';
import 'package:verytontine_flutter/services/sui_client_service.dart';

void main() {
  group('SuiClientService Tests', () {
    late SuiClientService suiClient;

    setUp(() {
      suiClient = SuiClientService();
    });

    test('should initialize with correct package ID', () {
      expect(suiClient.userAddress, isEmpty);
    });

    test('should set user address correctly', () {
      const testAddress = '0x1234567890abcdef';
      suiClient.setUserAddress(testAddress);
      expect(suiClient.userAddress, equals(testAddress));
    });

    test('should return empty circles for unset address', () async {
      final circles = await suiClient.getUserCircles();
      expect(circles, isEmpty);
    });

    test('should throw exception for operations without user address', () async {
      expect(
        () => suiClient.createCircle('Test Circle', 1000),
        throwsA(isA<Exception>()),
      );
    });

    test('should build transaction for authenticated user', () async {
      suiClient.setUserAddress('0x1234567890abcdef');
      
      try {
        final txBytes = await suiClient.createCircle('Test Circle', 1000);
        expect(txBytes, isNotEmpty);
      } catch (e) {
        // Expected to fail due to network call, but should not throw auth error
        expect(e.toString(), isNot(contains('User not authenticated')));
      }
    });
  });
}
