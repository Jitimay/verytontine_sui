import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.accent),
                        child: const Icon(Icons.savings_rounded, size: 48, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'VeryTontine',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Community savings on Sui — transparent rounds, shared vault, on-chain trust.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 36),
                    FilledButton.icon(
                      onPressed: () => context.read<AuthBloc>().add(ZkLoginRequested()),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.read<AuthBloc>().add(ZkLoginRequested()),
                      icon: const Icon(Icons.person_add_rounded, size: 20),
                      label: const Text('Create zkLogin account'),
                    ),
                    const SizedBox(height: 28),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading && state.message != null) {
                          return GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    state.message!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is AuthError) {
                          return GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.message,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.danger,
                                          fontSize: 13,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'No seed phrase to manage — zkLogin ties this app to your Google account and a Sui address.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          'Advanced · manual address',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
                        ),
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Display label'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _addressController,
                            decoration: const InputDecoration(labelText: 'Wallet address (optional)'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Full zkLogin still uses Google; this section is for local testing only.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
