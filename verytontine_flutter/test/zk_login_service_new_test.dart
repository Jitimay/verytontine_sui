import 'package:flutter_test/flutter_test.dart';
import 'package:verytontine_flutter/services/zk_login_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ZkLoginService New Tests', () {
    late ZkLoginService zkLoginService;

    setUp(() {
      zkLoginService = ZkLoginService();
    });

    test('should initialize with signed out state', () {
      expect(zkLoginService.isSignedIn, isFalse);
    });

    test(
      'should handle sign out correctly',
      () async {
        await zkLoginService.signOut();
        expect(zkLoginService.isSignedIn, isFalse);
      },
      skip: 'Requires Google Sign-In platform channel (run on device/integration)',
    );
  });
}
