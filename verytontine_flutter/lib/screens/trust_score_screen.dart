import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class TrustScoreScreen extends StatelessWidget {
  const TrustScoreScreen({super.key});

  static String _tierLabel(int score) {
    if (score >= 80) return 'Excellent standing';
    if (score >= 50) return 'Strong reliability';
    if (score >= 20) return 'Building history';
    return 'New participant';
  }

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
                  final score = circleState is CircleLoaded
                      ? circleState.userTrustScore
                      : authState.user.trustScore;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      Text(
                        'Trust',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'On-chain score from your savings circle activity.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.gold.withValues(alpha: 0.35),
                                    AppColors.goldDeep.withValues(alpha: 0.2),
                                  ],
                                ),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                              ),
                              child: const Icon(Icons.star_rounded, color: AppColors.gold, size: 44),
                            ),
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: score),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) {
                                return Text(
                                  '$value',
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gold,
                                    height: 1,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tierLabel(score),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Contributions',
                              value: '—',
                              color: AppColors.accent,
                              caption: 'From chain soon',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStat(
                              icon: Icons.event_busy_rounded,
                              label: 'Missed',
                              value: '—',
                              color: AppColors.danger,
                              caption: 'From chain soon',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text('Activity', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 40, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'No itemized history in the app yet',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scores update when you contribute through a circle. Explorer links can be added here later.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          Text(caption, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
