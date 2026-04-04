import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../theme/app_theme.dart';
import '../utils/sui_format.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              }
              return BlocBuilder<CircleBloc, CircleState>(
                builder: (context, circleState) {
                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () async {
                      context.read<CircleBloc>().add(LoadCircles());
                      await context.read<CircleBloc>().stream.firstWhere(
                            (s) => s is CircleLoaded || s is CircleError,
                          );
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppGradients.accent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    authState.user.name.isNotEmpty
                                        ? authState.user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        authState.user.name,
                                        style: Theme.of(context).textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GlassCard(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet_rounded,
                                              color: AppColors.accent.withValues(alpha: 0.9), size: 22),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Wallet',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.accent.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'Testnet',
                                              style: TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      SelectableText(
                                        authState.user.address,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.35,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextButton.icon(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: authState.user.address));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Address copied')),
                                          );
                                        },
                                        icon: const Icon(Icons.copy_rounded, size: 18),
                                        label: const Text('Copy address'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                GlassCard(
                                  padding: const EdgeInsets.all(22),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.gold.withValues(alpha: 0.15),
                                        ),
                                        child: const Icon(Icons.star_rounded, color: AppColors.gold, size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Trust score', style: Theme.of(context).textTheme.bodyMedium),
                                            Text(
                                              '${circleState is CircleLoaded ? circleState.userTrustScore : authState.user.trustScore}',
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                    color: AppColors.gold,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => Navigator.pushNamed(context, '/create-circle'),
                                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                        label: const Text('New circle'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => Navigator.pushNamed(context, '/join-circle'),
                                        icon: const Icon(Icons.group_add_rounded, size: 20),
                                        label: const Text('Join'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Text(
                                      'Your circles',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const Spacer(),
                                    if (circleState is CircleLoading)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        if (circleState is CircleError)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverToBoxAdapter(
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.danger),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        circleState.message,
                                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (circleState is CircleLoaded && circleState.circles.isEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverToBoxAdapter(child: _EmptyCircles(onCreate: () => Navigator.pushNamed(context, '/create-circle'))),
                          ),
                        if (circleState is CircleLoaded && circleState.circles.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final circle = circleState.circles[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GlassCard(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/circle-dashboard',
                                        arguments: circle,
                                      ),
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: AppGradients.accent,
                                            ),
                                            child: const Icon(Icons.groups_rounded, color: Colors.black, size: 24),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  circle.name,
                                                  style: Theme.of(context).textTheme.titleMedium,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${circle.members.length} members · Round ${circle.roundIndex + 1}',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                SuiFormat.formatMist(circle.vaultBalance.round()),
                                                style: const TextStyle(
                                                  color: AppColors.accent,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Pool',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                childCount: circleState.circles.length,
                              ),
                            ),
                          ),
                        if (circleState is! CircleLoaded && circleState is! CircleError && circleState is! CircleLoading)
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyCircles extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyCircles({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.groups_2_outlined, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text('No circles yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Create a savings circle or join one with an object ID from your organizer.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onCreate, child: const Text('Create a circle')),
        ],
      ),
    );
  }
}
