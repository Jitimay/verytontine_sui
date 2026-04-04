import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';
import '../services/sui_client_service.dart';

// ——— Events ———

abstract class CircleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadCircles extends CircleEvent {}

class CreateCircle extends CircleEvent {
  final String name;
  final int contributionAmount;
  CreateCircle({required this.name, required this.contributionAmount});
  @override
  List<Object> get props => [name, contributionAmount];
}

class JoinCircle extends CircleEvent {
  final String circleId;
  JoinCircle({required this.circleId});
  @override
  List<Object> get props => [circleId];
}

class ContributeToCircle extends CircleEvent {
  final String vaultId;
  final String circleId;
  final String trustScoreId;
  final int amount;
  ContributeToCircle({
    required this.vaultId,
    required this.circleId,
    required this.trustScoreId,
    required this.amount,
  });
  @override
  List<Object> get props => [vaultId, circleId, trustScoreId, amount];
}

class ExecutePayout extends CircleEvent {
  final String vaultId;
  final String circleId;
  ExecutePayout({required this.vaultId, required this.circleId});
  @override
  List<Object> get props => [vaultId, circleId];
}

class InitializeTrustScore extends CircleEvent {}

class CreateVault extends CircleEvent {
  final String circleId;
  CreateVault({required this.circleId});
  @override
  List<Object> get props => [circleId];
}

class SubmitSignedTransaction extends CircleEvent {
  final String transactionBytes;
  final String signature;
  SubmitSignedTransaction({required this.transactionBytes, required this.signature});
  @override
  List<Object> get props => [transactionBytes, signature];
}

// ——— States ———

abstract class CircleState extends Equatable {
  @override
  List<Object> get props => [];
}

class CircleInitial extends CircleState {}

class CircleLoading extends CircleState {
  final String? message;
  CircleLoading({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

class CircleLoaded extends CircleState {
  final List<Circle> circles;
  final int userTrustScore;
  CircleLoaded({required this.circles, this.userTrustScore = 0});
  @override
  List<Object> get props => [circles, userTrustScore];
}

class CircleError extends CircleState {
  final String message;
  CircleError({required this.message});
  @override
  List<Object> get props => [message];
}

class CircleOperationSuccess extends CircleState {
  final String message;
  final String? transactionDigest;
  CircleOperationSuccess({required this.message, this.transactionDigest});
  @override
  List<Object> get props => [message, transactionDigest ?? ''];
}

class TransactionPending extends CircleState {
  final String message;
  final String transactionBytes;
  TransactionPending({required this.message, required this.transactionBytes});
  @override
  List<Object> get props => [message, transactionBytes];
}

// ——— BLoC ———

class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final SuiClientService _suiClient = SuiClientService();

  CircleBloc() : super(CircleInitial()) {
    on<LoadCircles>(_onLoadCircles);
    on<CreateCircle>(_onCreateCircle);
    on<JoinCircle>(_onJoinCircle);
    on<ContributeToCircle>(_onContributeToCircle);
    on<ExecutePayout>(_onExecutePayout);
    on<InitializeTrustScore>(_onInitializeTrustScore);
    on<CreateVault>(_onCreateVault);
    on<SubmitSignedTransaction>(_onSubmitSignedTransaction);
  }

  Future<void> _onLoadCircles(LoadCircles event, Emitter<CircleState> emit) async {
    emit(CircleLoading(message: 'Loading circles…'));
    try {
      final circles = await _suiClient.getUserCircles();
      final trustScore = await _suiClient.getUserTrustScore();
      final enrichedCircles = <Circle>[];
      for (final circle in circles) {
        final vaults = await _suiClient.getCircleVaults(circle.id);
        double vaultBalance = 0.0;
        String? vaultId;
        if (vaults.isNotEmpty) {
          vaultId = vaults.first;
          vaultBalance = await _suiClient.getVaultBalance(vaults.first);
        }
        enrichedCircles.add(Circle(
          id: circle.id,
          name: circle.name,
          creator: circle.creator,
          members: circle.members,
          contributionAmount: circle.contributionAmount,
          roundIndex: circle.roundIndex,
          vaultBalance: vaultBalance,
          payoutOrder: circle.payoutOrder,
          vaultId: vaultId,
        ));
      }
      emit(CircleLoaded(circles: enrichedCircles, userTrustScore: trustScore));
    } catch (e) {
      emit(CircleError(message: 'Failed to load circles: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCircle(CreateCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading(message: 'Preparing circle…'));
    try {
      final txBytes = await _suiClient.createCircle(event.name, event.contributionAmount);
      emit(TransactionPending(
        message: 'Create savings circle',
        transactionBytes: txBytes,
      ));
    } catch (e) {
      emit(CircleError(message: 'Failed to create circle: ${e.toString()}'));
    }
  }

  Future<void> _onJoinCircle(JoinCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading(message: 'Preparing join…'));
    try {
      final txBytes = await _suiClient.joinCircle(event.circleId);
      emit(TransactionPending(
        message: 'Join savings circle',
        transactionBytes: txBytes,
      ));
    } catch (e) {
      emit(CircleError(message: 'Failed to join circle: ${e.toString()}'));
    }
  }

  Future<void> _onContributeToCircle(ContributeToCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading(message: 'Preparing contribution…'));
    try {
      final txBytes = await _suiClient.contribute(
        event.vaultId,
        event.circleId,
        event.trustScoreId,
        event.amount,
      );
      emit(TransactionPending(
        message: 'Contribute to pool',
        transactionBytes: txBytes,
      ));
    } catch (e) {
      emit(CircleError(message: 'Failed to contribute: ${e.toString()}'));
    }
  }

  Future<void> _onExecutePayout(ExecutePayout event, Emitter<CircleState> emit) async {
    emit(CircleLoading(message: 'Preparing payout…'));
    try {
      final txBytes = await _suiClient.executePayout(event.vaultId, event.circleId);
      emit(TransactionPending(
        message: 'Execute round payout',
        transactionBytes: txBytes,
      ));
    } catch (e) {
      emit(CircleError(message: 'Failed to execute payout: ${e.toString()}'));
    }
  }

  Future<void> _onInitializeTrustScore(InitializeTrustScore event, Emitter<CircleState> emit) async {
    emit(CircleLoading(message: 'Preparing trust profile…'));
    try {
      final txBytes = await _suiClient.initializeTrustScore();
      emit(TransactionPending(
        message: 'Initialize on-chain trust score',
        transactionBytes: txBytes,
      ));
    } catch (e) {
      emit(CircleError(message: 'Failed to initialize trust score: ${e.toString()}'));
    }
  }

  Future<void> _onCreateVault(CreateVault event, Emitter<CircleState> emit) async {
    emit(CircleLoading(message: 'Preparing vault…'));
    try {
      final txBytes = await _suiClient.createVault(event.circleId);
      emit(TransactionPending(
        message: 'Create vault for circle',
        transactionBytes: txBytes,
      ));
    } catch (e) {
      emit(CircleError(message: 'Failed to create vault: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitSignedTransaction(
    SubmitSignedTransaction event,
    Emitter<CircleState> emit,
  ) async {
    try {
      final result = await _suiClient.executeTransaction(event.transactionBytes, event.signature);
      final digest = result['digest'] as String?;
      emit(CircleOperationSuccess(
        message: 'Transaction confirmed on Sui',
        transactionDigest: digest,
      ));
      add(LoadCircles());
    } catch (e) {
      emit(CircleError(message: 'Transaction failed: ${e.toString()}'));
    }
  }
}
