import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';
import '../services/zk_login_service.dart';
import 'package:sui/sui.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String address;
  final String name;

  LoginRequested({required this.address, required this.name});

  @override
  List<Object> get props => [address, name];
}

class ZkLoginRequested extends AuthEvent {
  final String provider; // 'google', 'apple', etc.

  ZkLoginRequested({required this.provider});

  @override
  List<Object> get props => [provider];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? message;
  AuthLoading({this.message});
}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ZkLoginService _zkLoginService = ZkLoginService();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<ZkLoginRequested>(_onZkLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    final user = User(
      address: event.address,
      name: event.name,
      trustScore: 100,
    );
    emit(AuthAuthenticated(user: user));
  }

  void _onZkLoginRequested(ZkLoginRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading(message: 'Initializing zkLogin...'));
      
      // 1. Generate Ephemeral KeyPair
      final keyPair = Ed25519Keypair();
      final ephemeralPubKey = keyPair.getPublicKey();
      
      // 2. Mock OIDC flow (In real app, use google_sign_in)
      emit(AuthLoading(message: 'Waiting for OIDC...'));
      await Future.delayed(const Duration(seconds: 2));
      const mockJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      
      // 3. Fetch ZKP
      emit(AuthLoading(message: 'Generating Zero-Knowledge Proof...'));
      // In a real implementation we would call:
      // final zkp = await _zkLoginService.getZkProof(...);
      await Future.delayed(const Duration(seconds: 2));
      
      // 4. Complete Authentication
      final address = _zkLoginService.deriveZkLoginAddress(jwt: mockJwt, salt: 'MOCK_SALT');
      final user = User(
        address: address,
        name: 'zkUser',
        trustScore: 0,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}
