import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';
import '../models/models.dart';

class CircleDashboardScreen extends StatelessWidget {
  const CircleDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final circle = ModalRoute.of(context)!.settings.arguments as Circle;

    return Scaffold(
      appBar: AppBar(
        title: Text(circle.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: BlocListener<CircleBloc, CircleState>(
        listener: (context, state) {
          if (state is CircleLoaded) {
            // Refresh the screen with updated data
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Info Card
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Circle Info',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Chip(
                            label: Text('Round ${circle.roundIndex + 1}', style: const TextStyle(color: Colors.black)),
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Contribution Amount', style: TextStyle(color: Colors.grey)),
                              Text(
                                '\$${circle.contributionAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Vault Balance', style: TextStyle(color: Colors.grey)),
                              Text(
                                '\$${circle.vaultBalance.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Next Beneficiary Card
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Beneficiary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        circle.payoutOrder[circle.roundIndex % circle.payoutOrder.length],
                        style: const TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Members List
              const Text(
                'Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.grey[900],
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: circle.members.length,
                  itemBuilder: (context, index) {
                    final member = circle.members[index];
                    final isCurrentBeneficiary = member == circle.payoutOrder[circle.roundIndex % circle.payoutOrder.length];
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentBeneficiary ? Colors.green : Colors.grey,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(member, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        isCurrentBeneficiary ? 'Current beneficiary' : 'Member',
                        style: TextStyle(color: isCurrentBeneficiary ? Colors.green : Colors.grey),
                      ),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Contribute Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/contribution',
                            arguments: circle,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Contribute \$${circle.contributionAmount.toStringAsFixed(2)}'),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
