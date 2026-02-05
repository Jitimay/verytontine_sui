import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _membersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Circle'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: BlocListener<CircleBloc, CircleState>(
        listener: (context, state) {
          if (state is CircleLoaded) {
            Navigator.pop(context);
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
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Contribution Amount (\$)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _membersController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Member Addresses (one per line)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<CircleBloc, CircleState>(
                builder: (context, circleState) {
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: circleState is CircleLoading
                              ? null
                              : () {
                                  if (_nameController.text.isNotEmpty &&
                                      _amountController.text.isNotEmpty &&
                                      authState is AuthAuthenticated) {
                                    final members = [
                                      authState.user.address,
                                      ..._membersController.text
                                          .split('\n')
                                          .where((m) => m.trim().isNotEmpty)
                                          .map((m) => m.trim()),
                                    ];
                                    
                                    context.read<CircleBloc>().add(
                                          CreateCircle(
                                            name: _nameController.text,
                                            contributionAmount: double.parse(_amountController.text),
                                            members: members,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: circleState is CircleLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Create Circle'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _membersController.dispose();
    super.dispose();
  }
}
