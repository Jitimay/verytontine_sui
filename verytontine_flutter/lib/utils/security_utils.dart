import 'package:flutter/material.dart';

class InputValidator {
  static String? validateCircleName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Circle name is required';
    }
    if (value.trim().length < 3) {
      return 'Circle name must be at least 3 characters';
    }
    if (value.trim().length > 50) {
      return 'Circle name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value.trim())) {
      return 'Circle name can only contain letters, numbers, and spaces';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 1000000) {
      return 'Amount is too large';
    }
    return null;
  }

  static String? validateSuiAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (!value.startsWith('0x')) {
      return 'Address must start with 0x';
    }
    if (value.length != 66) {
      return 'Address must be 66 characters long';
    }
    if (!RegExp(r'^0x[a-fA-F0-9]{64}$').hasMatch(value)) {
      return 'Invalid address format';
    }
    return null;
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(String error)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? 
        Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text('Something went wrong', style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _error = null),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
    }

    return widget.child;
  }

  void _handleError(Object error) {
    setState(() {
      _error = error.toString();
    });
  }
}
