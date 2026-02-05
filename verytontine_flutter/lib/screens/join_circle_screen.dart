import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';

class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  final _circleIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Circle'),
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
              const Icon(
                Icons.add_circle,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Join an Existing Circle',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the circle ID to join',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _circleIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Circle ID',
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
                                  if (_circleIdController.text.isNotEmpty &&
                                      authState is AuthAuthenticated) {
                                    context.read<CircleBloc>().add(
                                          JoinCircle(
                                            circleId: _circleIdController.text,
                                            userAddress: authState.user.address,
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
                              : const Text('Join Circle'),
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
    _circleIdController.dispose();
    super.dispose();
  }
}
