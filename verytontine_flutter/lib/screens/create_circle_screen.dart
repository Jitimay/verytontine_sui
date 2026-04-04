import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../theme/app_theme.dart';
import '../utils/sui_format.dart';
import '../widgets/app_page_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final mist = SuiFormat.suiInputToMist(_amountController.text);
    if (name.isEmpty || mist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name and a valid contribution in SUI.')),
      );
      return;
    }
    context.read<CircleBloc>().add(CreateCircle(name: name, contributionAmount: mist));
  }

  @override
  Widget build(BuildContext context) {
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
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ],
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const AppPageHeader(
                    title: 'New circle',
                    subtitle: 'Fixed contribution per round · on-chain on Sui testnet',
                  ),
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.groups_rounded, color: AppColors.accent, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Members join on-chain after you share the circle object ID.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Circle name',
                            hintText: 'e.g. Family savings',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Contribution per round',
                            hintText: 'e.g. 0.5',
                            suffixText: 'SUI',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1 SUI = ${SuiFormat.mistPerSui} MIST. Everyone pays this exact amount each round.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<CircleBloc, CircleState>(
                    builder: (context, state) {
                      final busy = state is CircleLoading;
                      return FilledButton(
                        onPressed: busy ? null : _submit,
                        child: busy
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Text('Continue'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
