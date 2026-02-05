import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Card
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            child: Text(
                              state.user.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.user.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              state.user.address,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.grey[900],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '${state.user.trustScore}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                const SizedBox(height: 4),
                                const Text('Trust Score', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BlocBuilder<CircleBloc, CircleState>(
                          builder: (context, circleState) {
                            int groupCount = 0;
                            if (circleState is CircleLoaded) {
                              groupCount = circleState.circles.length;
                            }
                            return Card(
                              color: Colors.grey[900],
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      '$groupCount',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('Groups Joined', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Menu Items
                  Card(
                    color: Colors.grey[900],
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                          title: const Text('Wallet Settings', style: TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                          onTap: () {},
                        ),
                        const Divider(color: Colors.grey, height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.blue),
                          title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                          onTap: () {},
                        ),
                        const Divider(color: Colors.grey, height: 1),
                        ListTile(
                          leading: const Icon(Icons.security, color: Colors.orange),
                          title: const Text('Security', style: TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                          onTap: () {},
                        ),
                        const Divider(color: Colors.grey, height: 1),
                        ListTile(
                          leading: const Icon(Icons.help, color: Colors.purple),
                          title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Logout'),
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
}
