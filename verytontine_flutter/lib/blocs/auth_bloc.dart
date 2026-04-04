import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';
import '../models/auth_models.dart';
import '../services/zk_login_service.dart';
import '../services/sui_client_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ZkLoginRequested extends AuthEvent {}
class LogoutRequested extends AuthEvent {}
class SignTransaction extends AuthEvent {
  final String transactionBytes;
  SignTransaction({required this.transactionBytes});
  @override
  List<Object> get props => [transactionBytes];
}

/// Refetch trust score / object id after on-chain changes (e.g. new TrustScore object).
class ReloadTrustProfile extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? message;
  AuthLoading({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

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

class TransactionSigned extends AuthState {
  final String signature;
  final String transactionBytes;
  TransactionSigned({required this.signature, required this.transactionBytes});
  @override
  List<Object> get props => [signature, transactionBytes];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ZkLoginService _zkLoginService = ZkLoginService();
  final SuiClientService _suiClient = SuiClientService();
  User? _sessionUser;

  AuthBloc() : super(AuthInitial()) {
    on<ZkLoginRequested>(_onZkLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SignTransaction>(_onSignTransaction);
    on<ReloadTrustProfile>(_onReloadTrustProfile);
  }

  Future<void> _onZkLoginRequested(ZkLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading(message: 'Initializing zkLogin...'));
    
    try {
      // Perform zkLogin authentication
      emit(AuthLoading(message: 'Signing in with Google...'));
      final result = await _zkLoginService.signInWithGoogle();
      
      // Check if authentication was successful
      if (!result.success) {
        // Handle different error types
        if (result.errorType == AuthErrorType.userCancelled) {
          // Silent failure - return to initial state
          emit(AuthInitial());
          return;
        }
        
        // Show error message for other error types
        final errorMessage = result.errorType?.userMessage ?? result.errorMessage ?? 'Authentication failed';
        emit(AuthError(message: errorMessage));
        return;
      }
      
      // Authentication successful - get the Sui address
      final address = result.suiAddress!;
      
      // Set user address in Sui client
      _suiClient.setUserAddress(address);
      
      // Get user trust score
      emit(AuthLoading(message: 'Loading user data...'));
      final trustScore = await _suiClient.getUserTrustScore();
      final trustScoreObjectId = await _suiClient.getUserTrustScoreObjectId();

      final user = User(
        id: address,
        name: 'zkUser',
        address: address,
        trustScore: trustScore,
        trustScoreObjectId: trustScoreObjectId,
      );
      _sessionUser = user;

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Authentication failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignTransaction(SignTransaction event, Emitter<AuthState> emit) async {
    emit(AuthLoading(message: 'Signing transaction…'));
    
    try {
      final signature = await _zkLoginService.signTransaction(event.transactionBytes);
      emit(TransactionSigned(
        signature: signature,
        transactionBytes: event.transactionBytes,
      ));
      if (_sessionUser != null) {
        emit(AuthAuthenticated(user: _sessionUser!));
      }
    } catch (e) {
      emit(AuthError(message: 'Transaction signing failed: ${e.toString()}'));
      if (_sessionUser != null) {
        emit(AuthAuthenticated(user: _sessionUser!));
      }
    }
  }

  Future<void> _onReloadTrustProfile(ReloadTrustProfile event, Emitter<AuthState> emit) async {
    if (_sessionUser == null) return;
    try {
      _suiClient.setUserAddress(_sessionUser!.address);
      final trustScore = await _suiClient.getUserTrustScore();
      final trustScoreObjectId = await _suiClient.getUserTrustScoreObjectId();
      _sessionUser = User(
        id: _sessionUser!.id,
        address: _sessionUser!.address,
        name: _sessionUser!.name,
        trustScore: trustScore,
        trustScoreObjectId: trustScoreObjectId,
      );
      emit(AuthAuthenticated(user: _sessionUser!));
    } catch (_) {
      /* keep previous session */
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading(message: 'Signing out…'));
    
    try {
      await _zkLoginService.signOut();
      _sessionUser = null;
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: ${e.toString()}'));
    }
  }
}
