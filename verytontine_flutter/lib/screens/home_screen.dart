import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/circle_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circles'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.user.name, style: const TextStyle(color: Colors.white)),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Logout'),
                      onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: BlocBuilder<CircleBloc, CircleState>(
          builder: (context, state) {
            if (state is CircleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is CircleLoaded) {
              if (state.circles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No circles yet', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text('Create or join a savings circle to get started', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/create-circle'),
                        child: const Text('Create Circle'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.circles.length,
                itemBuilder: (context, index) {
                  final circle = state.circles[index];
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.group, color: Colors.white),
                      ),
                      title: Text(circle.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${circle.members.length} members • \$${circle.contributionAmount}', 
                        style: const TextStyle(color: Colors.grey)),
                      trailing: Text('\$${circle.vaultBalance.toStringAsFixed(2)}', 
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/circle-dashboard',
                        arguments: circle,
                      ),
                    ),
                  );
                },
              );
            }
            
            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "join",
            onPressed: () => Navigator.pushNamed(context, '/join-circle'),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add_circle),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "create",
            onPressed: () => Navigator.pushNamed(context, '/create-circle'),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
