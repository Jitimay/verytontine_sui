import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verytontine_flutter/screens/login_screen.dart';
import 'package:verytontine_flutter/blocs/auth_bloc.dart';

void main() {
  testWidgets('LoginScreen shows Google Sign In button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => AuthBloc(),
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('VeryTontine'), findsOneWidget);
  });
}
