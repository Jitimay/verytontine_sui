import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        'Confirm Transaction',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Transaction Details:',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signature: ${signature.substring(0, 20)}...',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'TX Bytes: ${transactionBytes.substring(0, 20)}...',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Please review the transaction details before confirming.',
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.black,
          ),
          child: const Text('Confirm'),
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
    showDialog(
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
