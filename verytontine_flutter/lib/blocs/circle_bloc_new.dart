import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';
import '../services/sui_client_service.dart';

// Events
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
  ContributeToCircle({required this.vaultId, required this.circleId, required this.trustScoreId, required this.amount});
  @override
  List<Object> get props => [vaultId, circleId, trustScoreId, amount];
}

// States
abstract class CircleState extends Equatable {
  @override
  List<Object> get props => [];
}

class CircleInitial extends CircleState {}
class CircleLoading extends CircleState {}
class CircleLoaded extends CircleState {
  final List<Circle> circles;
  CircleLoaded({required this.circles});
  @override
  List<Object> get props => [circles];
}
class CircleError extends CircleState {
  final String message;
  CircleError({required this.message});
  @override
  List<Object> get props => [message];
}
class CircleOperationSuccess extends CircleState {
  final String message;
  CircleOperationSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

// BLoC
class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final SuiClientService _suiClient = SuiClientService();

  CircleBloc() : super(CircleInitial()) {
    on<LoadCircles>(_onLoadCircles);
    on<CreateCircle>(_onCreateCircle);
    on<JoinCircle>(_onJoinCircle);
    on<ContributeToCircle>(_onContributeToCircle);
  }

  Future<void> _onLoadCircles(LoadCircles event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    try {
      final circles = await _suiClient.getUserCircles();
      emit(CircleLoaded(circles: circles));
    } catch (e) {
      emit(CircleError(message: e.toString()));
    }
  }

  Future<void> _onCreateCircle(CreateCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    try {
      await _suiClient.createCircle(event.name, event.contributionAmount);
      emit(CircleOperationSuccess(message: 'Circle created successfully'));
      add(LoadCircles());
    } catch (e) {
      emit(CircleError(message: e.toString()));
    }
  }

  Future<void> _onJoinCircle(JoinCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    try {
      await _suiClient.joinCircle(event.circleId);
      emit(CircleOperationSuccess(message: 'Joined circle successfully'));
      add(LoadCircles());
    } catch (e) {
      emit(CircleError(message: e.toString()));
    }
  }

  Future<void> _onContributeToCircle(ContributeToCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    try {
      await _suiClient.contribute(event.vaultId, event.circleId, event.trustScoreId, event.amount);
      emit(CircleOperationSuccess(message: 'Contribution successful'));
      add(LoadCircles());
    } catch (e) {
      emit(CircleError(message: e.toString()));
    }
  }
}
