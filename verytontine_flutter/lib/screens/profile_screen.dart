import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../theme/app_theme.dart';
import '../utils/sui_format.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (p, c) => c is TransactionSuccess,
      listener: (context, state) {
        context.read<AuthBloc>().add(ReloadTrustProfile());
      },
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
              if (state is! AuthAuthenticated) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Row(
                    children: [
                      Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                        icon: const Icon(Icons.logout_rounded),
                        tooltip: 'Sign out',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.accent),
                          alignment: Alignment.center,
                          child: Text(
                            state.user.name.isNotEmpty ? state.user.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(state.user.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        SelectableText(
                          state.user.address,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                            height: 1.4,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: state.user.address));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Address copied')),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<CircleBloc, CircleState>(
                    builder: (context, circleState) {
                      final trust = circleState is CircleLoaded
                          ? circleState.userTrustScore
                          : state.user.trustScore;
                      final groups = circleState is CircleLoaded ? circleState.circles.length : 0;
                      return Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.gold),
                                  const SizedBox(height: 10),
                                  Text('$trust', style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w800)),
                                  Text('Trust score', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.groups_rounded, color: AppColors.cyan),
                                  const SizedBox(height: 10),
                                  Text('$groups', style: const TextStyle(color: AppColors.cyan, fontSize: 24, fontWeight: FontWeight.w800)),
                                  Text('Circles', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (state.user.trustScoreObjectId == null) ...[
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('On-chain trust', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Initialize your trust score object once to participate in contributions.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.tonal(
                            onPressed: () => context.read<CircleBloc>().add(InitializeTrustScore()),
                            child: const Text('Initialize trust score'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Account', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.link_rounded,
                          title: 'Sui testnet',
                          subtitle: SuiFormat.shortenAddress(state.user.address),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _ProfileTile(
                          icon: Icons.shield_outlined,
                          title: 'Security',
                          subtitle: 'zkLogin session',
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _ProfileTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Support',
                          subtitle: 'Documentation & help',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accent),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }
}
