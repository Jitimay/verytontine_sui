import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verytontine_flutter/screens/login_screen.dart';
import 'package:verytontine_flutter/blocs/auth_bloc.dart';

void main() {
  testWidgets('LoginScreen shows progress message after clicking Google Sign In', (WidgetTester tester) async {
    // 1. Build the widget with a real but isolated AuthBloc
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => AuthBloc(),
          child: const LoginScreen(),
        ),
      ),
    );

    // 2. Find and tap the Google Sign In button
    final googleButton = find.text('Sign in with Google');
    expect(googleButton, findsOneWidget);
    
    await tester.tap(googleButton);
    await tester.pump(); // Show initial loading message

    // 3. Verify that the loading message appears
    expect(find.text('Initializing zkLogin...'), findsOneWidget);

    // 4. Wait for the mock flow to complete
    await tester.pumpAndSettle(); 
  });
}
