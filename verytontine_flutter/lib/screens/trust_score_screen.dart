import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class TrustScoreScreen extends StatelessWidget {
  const TrustScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Trust Score'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Trust Score Card
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Your Trust Score',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${state.user.trustScore}',
                            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Excellent',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.grey[900],
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('12', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                                SizedBox(height: 4),
                                Text('On-time Payments', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          color: Colors.grey[900],
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                                SizedBox(height: 4),
                                Text('Missed Payments', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment History
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Payment History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // History List
                  Card(
                    color: Colors.grey[900],
                    child: Column(
                      children: [
                        _buildHistoryItem('Family Circle', '\$50.00', 'Jan 15, 2024', true),
                        _buildHistoryItem('Friends Group', '\$25.00', 'Jan 10, 2024', true),
                        _buildHistoryItem('Work Colleagues', '\$100.00', 'Jan 5, 2024', true),
                        _buildHistoryItem('Community Fund', '\$75.00', 'Dec 28, 2023', true),
                        _buildHistoryItem('Savings Club', '\$30.00', 'Dec 20, 2023', true),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHistoryItem(String circleName, String amount, String date, bool onTime) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: onTime ? Colors.green : Colors.red,
        child: Icon(
          onTime ? Icons.check : Icons.close,
          color: Colors.white,
        ),
      ),
      title: Text(circleName, style: const TextStyle(color: Colors.white)),
      subtitle: Text(date, style: const TextStyle(color: Colors.grey)),
      trailing: Text(
        amount,
        style: TextStyle(
          color: onTime ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
