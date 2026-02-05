import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF87).withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 60,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Welcome to VeryTontine',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00FF87).withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Secure community savings on Sui blockchain',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00FF87),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Quick Sign In Buttons
                    _buildGlassButton(
                      'Sign in with Google',
                      Icons.login,
                      const LinearGradient(colors: [Colors.white, Colors.grey]),
                      Colors.black,
                      () => context.read<AuthBloc>().add(LoginRequested(address: '0x1234...abcd', name: 'Demo User')),
                    ),
                    const SizedBox(height: 16),
                    _buildGlassButton(
                      'Create Account',
                      Icons.person_add,
                      LinearGradient(colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]),
                      const Color(0xFF00FF87),
                      () => context.read<AuthBloc>().add(LoginRequested(address: '0x5678...efgh', name: 'New User')),
                      isOutlined: true,
                    ),
                    const SizedBox(height: 40),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Text(
                        'No crypto knowledge needed\nJust save with your community',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Manual Entry (Hidden by default)
                    ExpansionTile(
                      title: Text(
                        'Manual Entry',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                      ),
                      iconColor: Colors.white.withValues(alpha: 0.7),
                      collapsedIconColor: Colors.white.withValues(alpha: 0.7),
                      children: [
                        const SizedBox(height: 16),
                        _buildGlassTextField(_nameController, 'Your Name', Icons.person),
                        const SizedBox(height: 16),
                        _buildGlassTextField(_addressController, 'Wallet Address', Icons.account_balance_wallet),
                        const SizedBox(height: 24),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return _buildGlassButton(
                              'Connect Wallet',
                              Icons.link,
                              const LinearGradient(colors: [Color(0xFF00FF87), Color(0xFF60EFFF)]),
                              Colors.black,
                              state is AuthLoading ? null : () {
                                if (_nameController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                                  context.read<AuthBloc>().add(
                                    LoginRequested(address: _addressController.text, name: _nameController.text),
                                  );
                                }
                              },
                              isLoading: state is AuthLoading,
                            );
                          },
                        ),
                      ],
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(String text, IconData icon, Gradient gradient, Color textColor, VoidCallback? onPressed, {bool isOutlined = false, bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isOutlined ? null : gradient,
        border: isOutlined ? Border.all(color: const Color(0xFF00FF87), width: 1) : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon, color: textColor),
        label: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildGlassTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: const Color(0xFF00FF87)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
