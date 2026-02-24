import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/circle_bloc_new.dart';
import '../blocs/transaction_bloc.dart';
import '../widgets/transaction_handler.dart';

class CreateCircleExample extends StatefulWidget {
  const CreateCircleExample({super.key});

  @override
  State<CreateCircleExample> createState() => _CreateCircleExampleState();
}

class _CreateCircleExampleState extends State<CreateCircleExample> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TransactionHandler(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Circle'),
          backgroundColor: Colors.black,
        ),
        body: BlocListener<CircleBloc, CircleState>(
          listener: (context, state) {
            if (state is TransactionPending) {
              // Trigger transaction signing
              context.read<TransactionBloc>().add(
                SignAndExecuteTransaction(
                  transactionBytes: state.transactionBytes,
                  description: state.message,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Circle Name',
                    labelStyle: TextStyle(color: Colors.green),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Contribution Amount (SUI)',
                    labelStyle: TextStyle(color: Colors.green),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<CircleBloc, CircleState>(
                  builder: (context, state) {
                    final isLoading = state is CircleLoading;
                    
                    return ElevatedButton(
                      onPressed: isLoading ? null : _createCircle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Create Circle'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createCircle() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    
    if (name.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Convert SUI to MIST (1 SUI = 1,000,000,000 MIST)
    final amountInMist = amount * 1000000000;
    
    context.read<CircleBloc>().add(
      CreateCircle(name: name, contributionAmount: amountInMist),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
