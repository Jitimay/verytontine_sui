import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';
import '../services/zk_login_service.dart';
import '../services/sui_client_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ZkLoginRequested extends AuthEvent {}
class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated({required this.user});
  @override
  List<Object> get props => [user];
}
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ZkLoginService _zkLoginService = ZkLoginService();
  final SuiClientService _suiClient = SuiClientService();

  AuthBloc() : super(AuthInitial()) {
    on<ZkLoginRequested>(_onZkLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onZkLoginRequested(ZkLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _suiClient.initialize();
      final address = await _zkLoginService.signInWithGoogle();
      final user = User(id: address, name: 'User', address: address);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
}

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
