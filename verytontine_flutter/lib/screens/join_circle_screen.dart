import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/app_page_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
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
    _idController.dispose();
    super.dispose();
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
                    title: 'Join circle',
                    subtitle: 'Paste the shared Circle object ID (0x…)',
                  ),
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _idController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Circle object ID',
                            hintText: '0x…',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 20, color: AppColors.cyan.withValues(alpha: 0.9)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ask the circle creator for this ID. It identifies the shared circle on Sui testnet.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<CircleBloc, CircleState>(
                    builder: (context, state) {
                      final busy = state is CircleLoading;
                      return FilledButton(
                        onPressed: busy
                            ? null
                            : () {
                                final id = _idController.text.trim();
                                if (id.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Enter a circle object ID.')),
                                  );
                                  return;
                                }
                                context.read<CircleBloc>().add(JoinCircle(circleId: id));
                              },
                        child: busy
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Text('Request to join'),
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
