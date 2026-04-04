import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../theme/app_theme.dart';
import 'transaction_confirmation_dialog.dart';

class TransactionHandler extends StatelessWidget {
  final Widget child;

  const TransactionHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSigning) {
          _showLoadingDialog(context, 'Signing with your wallet…');
        } else if (state is TransactionReadyForConfirmation) {
          Navigator.of(context).pop();
          TransactionConfirmationDialog.show(
            context,
            description: state.description,
            signature: state.signature,
            transactionBytes: state.transactionBytes,
          );
        } else if (state is TransactionExecuting) {
          _showLoadingDialog(context, 'Submitting to Sui…');
        } else if (state is TransactionSuccess) {
          Navigator.of(context).pop();
          _showResultDialog(
            context,
            title: 'Done',
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.accent,
            message: state.message,
            digest: state.transactionDigest,
          );
        } else if (state is TransactionError) {
          Navigator.of(context).pop();
          _showResultDialog(
            context,
            title: 'Something went wrong',
            icon: Icons.error_outline_rounded,
            iconColor: AppColors.danger,
            message: state.message,
            digest: null,
          );
        }
      },
      child: child,
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
            const SizedBox(width: 20),
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String message,
    required String? digest,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, style: TextStyle(color: iconColor, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: AppColors.textPrimary)),
            if (digest != null) ...[
              const SizedBox(height: 14),
              const Text('Digest', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              SelectableText(
                digest,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
