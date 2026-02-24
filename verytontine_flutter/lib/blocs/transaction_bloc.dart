import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'auth_bloc.dart';
import 'circle_bloc_new.dart';

// Events
abstract class TransactionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SignAndExecuteTransaction extends TransactionEvent {
  final String transactionBytes;
  final String description;
  
  SignAndExecuteTransaction({
    required this.transactionBytes,
    required this.description,
  });
  
  @override
  List<Object> get props => [transactionBytes, description];
}

class ConfirmTransaction extends TransactionEvent {
  final String signature;
  final String transactionBytes;
  
  ConfirmTransaction({
    required this.signature,
    required this.transactionBytes,
  });
  
  @override
  List<Object> get props => [signature, transactionBytes];
}

// States
abstract class TransactionState extends Equatable {
  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionSigning extends TransactionState {
  final String description;
  TransactionSigning({required this.description});
  @override
  List<Object> get props => [description];
}

class TransactionReadyForConfirmation extends TransactionState {
  final String description;
  final String signature;
  final String transactionBytes;
  
  TransactionReadyForConfirmation({
    required this.description,
    required this.signature,
    required this.transactionBytes,
  });
  
  @override
  List<Object> get props => [description, signature, transactionBytes];
}

class TransactionExecuting extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final String message;
  final String? transactionDigest;
  
  TransactionSuccess({
    required this.message,
    this.transactionDigest,
  });
  
  @override
  List<Object> get props => [message, transactionDigest ?? ''];
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError({required this.message});
  @override
  List<Object> get props => [message];
}

// BLoC
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AuthBloc authBloc;
  final CircleBloc circleBloc;
  
  TransactionBloc({
    required this.authBloc,
    required this.circleBloc,
  }) : super(TransactionInitial()) {
    on<SignAndExecuteTransaction>(_onSignAndExecuteTransaction);
    on<ConfirmTransaction>(_onConfirmTransaction);
  }

  Future<void> _onSignAndExecuteTransaction(
    SignAndExecuteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionSigning(description: event.description));
    
    try {
      // Request signature from AuthBloc
      authBloc.add(SignTransaction(transactionBytes: event.transactionBytes));
      
      // Wait for signature
      await for (final authState in authBloc.stream) {
        if (authState is TransactionSigned) {
          emit(TransactionReadyForConfirmation(
            description: event.description,
            signature: authState.signature,
            transactionBytes: authState.transactionBytes,
          ));
          break;
        } else if (authState is AuthError) {
          emit(TransactionError(message: authState.message));
          break;
        }
      }
    } catch (e) {
      emit(TransactionError(message: 'Transaction signing failed: ${e.toString()}'));
    }
  }

  Future<void> _onConfirmTransaction(
    ConfirmTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionExecuting());
    
    try {
      // Execute transaction through CircleBloc
      await circleBloc.executeSignedTransaction(
        event.transactionBytes,
        event.signature,
      );
      
      // Wait for execution result
      await for (final circleState in circleBloc.stream) {
        if (circleState is CircleOperationSuccess) {
          emit(TransactionSuccess(
            message: circleState.message,
            transactionDigest: circleState.transactionDigest,
          ));
          break;
        } else if (circleState is CircleError) {
          emit(TransactionError(message: circleState.message));
          break;
        }
      }
    } catch (e) {
      emit(TransactionError(message: 'Transaction execution failed: ${e.toString()}'));
    }
  }
}
