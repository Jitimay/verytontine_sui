import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../theme/app_theme.dart';

class TransactionConfirmationDialog extends StatelessWidget {
  final String description;
  final String signature;
  final String transactionBytes;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const TransactionConfirmationDialog({
    super.key,
    required this.description,
    required this.signature,
    required this.transactionBytes,
    this.onConfirm,
    this.onCancel,
  });

  static String _preview(String value, int max) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}…';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Row(
        children: [
          Icon(Icons.fingerprint_rounded, color: AppColors.accent.withValues(alpha: 0.9)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Confirm on-chain action',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'You are about to submit a transaction to Sui testnet. This may move SUI from your wallet and cannot be undone from the app.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                'Payload preview\n${_preview(transactionBytes, 48)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Signature ${_preview(signature, 32)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            context.read<TransactionBloc>().add(
                  ConfirmTransaction(
                    signature: signature,
                    transactionBytes: transactionBytes,
                  ),
                );
            onConfirm?.call();
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required String description,
    required String signature,
    required String transactionBytes,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransactionConfirmationDialog(
        description: description,
        signature: signature,
        transactionBytes: transactionBytes,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
