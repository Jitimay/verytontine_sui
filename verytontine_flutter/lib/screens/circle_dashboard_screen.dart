import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/sui_format.dart';
import '../widgets/app_page_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class CircleDashboardScreen extends StatelessWidget {
  const CircleDashboardScreen({super.key});

  Circle _mergeCircle(Circle initial, CircleState state) {
    if (state is! CircleLoaded) return initial;
    for (final c in state.circles) {
      if (c.id == initial.id) return c;
    }
    return initial;
  }

  String _beneficiaryLabel(Circle circle) {
    if (circle.payoutOrder.isEmpty) return '—';
    final i = circle.roundIndex % circle.payoutOrder.length;
    return SuiFormat.shortenAddress(circle.payoutOrder[i]);
  }

  @override
  Widget build(BuildContext context) {
    final initial = ModalRoute.of(context)!.settings.arguments as Circle;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<CircleBloc, CircleState>(
            builder: (context, state) {
              final circle = _mergeCircle(initial, state);
              final auth = context.watch<AuthBloc>().state;
              final isCreator =
                  auth is AuthAuthenticated && auth.user.address == circle.creator;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  AppPageHeader(
                    title: circle.name,
                    subtitle: 'Round ${circle.roundIndex + 1} · ${circle.members.length} members',
                  ),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contribution (fixed)', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Text(
                          SuiFormat.formatMist(circle.contributionAmount.round()),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pool balance', style: Theme.of(context).textTheme.bodyMedium),
                                Text(
                                  SuiFormat.formatMist(circle.vaultBalance.round()),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            if (isCreator && circle.vaultId == null)
                              TextButton.icon(
                                onPressed: () {
                                  context.read<CircleBloc>().add(CreateVault(circleId: circle.id));
                                },
                                icon: const Icon(Icons.add_moderator_outlined, size: 18),
                                label: const Text('Create vault'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current beneficiary', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        SelectableText(
                          _beneficiaryLabel(circle),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Members', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < circle.members.length; i++)
                          _MemberRow(
                            index: i + 1,
                            address: circle.members[i],
                            isLast: i == circle.members.length - 1,
                            highlight: circle.payoutOrder.isNotEmpty &&
                                circle.members[i] ==
                                    circle.payoutOrder[circle.roundIndex % circle.payoutOrder.length],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (auth is AuthAuthenticated) ...[
                    FilledButton.icon(
                      onPressed: circle.vaultId == null
                          ? null
                          : () => Navigator.pushNamed(context, '/contribution', arguments: circle),
                      icon: const Icon(Icons.savings_outlined),
                      label: Text('Contribute ${SuiFormat.formatMist(circle.contributionAmount.round())}'),
                    ),
                    if (circle.vaultId == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'The creator must create a vault before contributions can be made.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ),
                    if (isCreator) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: circle.vaultId == null
                            ? null
                            : () {
                                context.read<CircleBloc>().add(
                                      ExecutePayout(vaultId: circle.vaultId!, circleId: circle.id),
                                    );
                              },
                        icon: const Icon(Icons.outbound_rounded),
                        label: const Text('Run payout (creator)'),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final int index;
  final String address;
  final bool highlight;
  final bool isLast;

  const _MemberRow({
    required this.index,
    required this.address,
    required this.highlight,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: highlight ? AppColors.accent.withValues(alpha: 0.2) : AppColors.surfaceElevated,
          foregroundColor: highlight ? AppColors.accent : AppColors.textSecondary,
          child: Text('$index', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        title: Text(
          SuiFormat.shortenAddress(address),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          highlight ? 'Receives this round' : 'Member',
          style: TextStyle(color: highlight ? AppColors.accent : AppColors.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
