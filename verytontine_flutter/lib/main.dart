import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/circle_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/create_circle_screen.dart';
import 'screens/join_circle_screen.dart';
import 'screens/circle_dashboard_screen.dart';
import 'screens/contribution_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => CircleBloc()..add(LoadCircles())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,  
        title: 'VeryTontine',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ).copyWith(
            surface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1E1E1E),
            elevation: 4,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MainNavigationScreen(),
          '/create-circle': (context) => const CreateCircleScreen(),
          '/join-circle': (context) => const JoinCircleScreen(),
          '/circle-dashboard': (context) => const CircleDashboardScreen(),
          '/contribution': (context) => const ContributionScreen(),
        },
      ),
    );
  }
}
