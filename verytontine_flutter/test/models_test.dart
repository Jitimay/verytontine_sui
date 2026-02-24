import 'package:flutter_test/flutter_test.dart';
import 'package:verytontine_flutter/models/models.dart';

void main() {
  group('Circle Model Tests', () {
    test('should create Circle from valid Sui object', () {
      final mockSuiObject = {
        'data': {
          'objectId': '0x123',
          'content': {
            'fields': {
              'name': 'Test Circle',
              'creator': '0xabc',
              'members': ['0xabc', '0xdef'],
              'contribution_amount': '1000',
              'round_index': '0',
              'payout_order': ['0xabc', '0xdef'],
            }
          }
        }
      };

      final circle = Circle.fromSuiObject(mockSuiObject);

      expect(circle.id, equals('0x123'));
      expect(circle.name, equals('Test Circle'));
      expect(circle.creator, equals('0xabc'));
      expect(circle.members, hasLength(2));
      expect(circle.contributionAmount, equals(1000.0));
      expect(circle.roundIndex, equals(0));
      expect(circle.payoutOrder, hasLength(2));
    });

    test('should handle malformed Sui object gracefully', () {
      final mockSuiObject = {
        'data': {
          'objectId': '0x123',
          'content': {
            'fields': {
              'name': null,
              'invalid_field': 'test',
            }
          }
        }
      };

      final circle = Circle.fromSuiObject(mockSuiObject);

      expect(circle.id, equals('0x123'));
      expect(circle.name, equals('Unknown Circle'));
      expect(circle.members, isEmpty);
      expect(circle.contributionAmount, equals(0.0));
    });

    test('should handle completely invalid object', () {
      final mockSuiObject = {'invalid': 'data'};

      final circle = Circle.fromSuiObject(mockSuiObject);

      expect(circle.name, equals('Unknown Circle'));
      expect(circle.members, isEmpty);
    });
  });

  group('User Model Tests', () {
    test('should create User with default trust score', () {
      const user = User(
        id: '0x123',
        address: '0x123',
        name: 'Test User',
      );

      expect(user.trustScore, equals(0));
    });

    test('should create User with custom trust score', () {
      const user = User(
        id: '0x123',
        address: '0x123',
        name: 'Test User',
        trustScore: 100,
      );

      expect(user.trustScore, equals(100));
    });
  });
}
