import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/circle_bloc.dart';
import 'blocs/transaction_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/create_circle_screen.dart';
import 'screens/join_circle_screen.dart';
import 'screens/circle_dashboard_screen.dart';
import 'screens/contribution_screen.dart';
import 'theme/app_theme.dart';
import 'utils/config_validator.dart';
import 'widgets/transaction_handler.dart';

void main() {
  ConfigValidator.printWarnings();
  runApp(const VeryTontineApp());
}

class VeryTontineApp extends StatelessWidget {
  const VeryTontineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => CircleBloc()..add(LoadCircles())),
        BlocProvider(
          create: (context) => TransactionBloc(
            authBloc: context.read<AuthBloc>(),
            circleBloc: context.read<CircleBloc>(),
          ),
        ),
      ],
      child: TransactionHandler(
        child: BlocListener<CircleBloc, CircleState>(
          listenWhen: (prev, curr) => curr is TransactionPending,
          listener: (context, state) {
            if (state is TransactionPending) {
              context.read<TransactionBloc>().add(
                    SignAndExecuteTransaction(
                      transactionBytes: state.transactionBytes,
                      description: state.message,
                    ),
                  );
            }
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VeryTontine',
            theme: buildAppTheme(),
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
        ),
      ),
    );
  }
}
