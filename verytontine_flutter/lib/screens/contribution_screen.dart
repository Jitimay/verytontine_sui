import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/sui_format.dart';
import '../widgets/app_page_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class ContributionScreen extends StatelessWidget {
  const ContributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final circle = ModalRoute.of(context)!.settings.arguments as Circle;

    return MultiBlocListener(
      listeners: [
        BlocListener<CircleBloc, CircleState>(
          listener: (context, state) {
            if (state is CircleError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<TransactionBloc, TransactionState>(
          listenWhen: (p, c) => c is TransactionSuccess,
          listener: (context, state) {
            context.read<AuthBloc>().add(ReloadTrustProfile());
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ],
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! AuthAuthenticated) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                }
                final trustId = authState.user.trustScoreObjectId;
                final vaultId = circle.vaultId;
                final amount = circle.contributionAmount.round();
                final canSubmit = vaultId != null && trustId != null;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const AppPageHeader(
                      title: 'Contribute',
                      subtitle: 'Exact amount required by the circle smart contract',
                    ),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(circle.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 20),
                          Text(
                            SuiFormat.formatMist(amount),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gas is paid from your SUI balance when you confirm the transaction.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (trustId == null) ...[
                      const SizedBox(height: 16),
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.verified_user_outlined, color: AppColors.gold.withValues(alpha: 0.9)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Register your on-chain trust score once to contribute.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            FilledButton.tonal(
                              onPressed: () {
                                context.read<CircleBloc>().add(InitializeTrustScore());
                              },
                              child: const Text('Initialize trust score'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (vaultId == null) ...[
                      const SizedBox(height: 16),
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          'No vault is linked to this circle yet. Ask the creator to create the vault from the circle dashboard.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: !canSubmit
                          ? null
                          : () {
                              context.read<CircleBloc>().add(
                                    ContributeToCircle(
                                      vaultId: vaultId,
                                      circleId: circle.id,
                                      trustScoreId: trustId,
                                      amount: amount,
                                    ),
                                  );
                            },
                      child: const Text('Sign & submit contribution'),
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
