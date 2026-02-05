import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class TrustScoreScreen extends StatefulWidget {
  const TrustScoreScreen({super.key});

  @override
  State<TrustScoreScreen> createState() => _TrustScoreScreenState();
}

class _TrustScoreScreenState extends State<TrustScoreScreen> with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _pulseController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    
    _scoreAnimation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _pulseController.dispose();
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
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 80,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      flexibleSpace: const FlexibleSpaceBar(
                        title: Text(
                          'Trust Score',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        centerTitle: true,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Trust Score Display
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFFFD700).withValues(alpha: 0.2),
                                        const Color(0xFFFFD700).withValues(alpha: 0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.black,
                                          size: 50,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Your Trust Score',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      AnimatedBuilder(
                                        animation: _scoreAnimation,
                                        builder: (context, child) {
                                          return Text(
                                            '${_scoreAnimation.value.toInt()}',
                                            style: const TextStyle(
                                              fontSize: 64,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFD700),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                          ),
                                        ),
                                        child: const Text(
                                          'Excellent',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          
                          // Stats Cards
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('12', 'On-time\nPayments', const Color(0xFF00FF87), Icons.check_circle)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard('0', 'Missed\nPayments', Colors.red, Icons.cancel)),
                            ],
                          ),
                          const SizedBox(height: 30),
                          
                          // Payment History Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00FF87).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.history,
                                  color: Color(0xFF00FF87),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Payment History',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // History List
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildHistoryItem('Family Circle', '\$50.00', 'Jan 15, 2024', true),
                                _buildDivider(),
                                _buildHistoryItem('Friends Group', '\$25.00', 'Jan 10, 2024', true),
                                _buildDivider(),
                                _buildHistoryItem('Work Colleagues', '\$100.00', 'Jan 5, 2024', true),
                                _buildDivider(),
                                _buildHistoryItem('Community Fund', '\$75.00', 'Dec 28, 2023', true),
                                _buildDivider(),
                                _buildHistoryItem('Savings Club', '\$30.00', 'Dec 20, 2023', true),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String circleName, String amount, String date, bool onTime) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: onTime 
                  ? [const Color(0xFF00FF87), const Color(0xFF60EFFF)]
                  : [Colors.red, Colors.redAccent],
              ),
            ),
            child: Icon(
              onTime ? Icons.check : Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  circleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: onTime ? const Color(0xFF00FF87) : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}
