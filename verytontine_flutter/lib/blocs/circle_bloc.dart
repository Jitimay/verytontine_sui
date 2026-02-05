import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';

// Events
abstract class CircleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadCircles extends CircleEvent {}

class CreateCircle extends CircleEvent {
  final String name;
  final double contributionAmount;
  final List<String> members;

  CreateCircle({
    required this.name,
    required this.contributionAmount,
    required this.members,
  });

  @override
  List<Object> get props => [name, contributionAmount, members];
}

class JoinCircle extends CircleEvent {
  final String circleId;
  final String userAddress;

  JoinCircle({required this.circleId, required this.userAddress});

  @override
  List<Object> get props => [circleId, userAddress];
}

class ContributeToCircle extends CircleEvent {
  final String circleId;
  final String userAddress;

  ContributeToCircle({required this.circleId, required this.userAddress});

  @override
  List<Object> get props => [circleId, userAddress];
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

// BLoC
class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final List<Circle> _circles = [];

  CircleBloc() : super(CircleInitial()) {
    on<LoadCircles>(_onLoadCircles);
    on<CreateCircle>(_onCreateCircle);
    on<JoinCircle>(_onJoinCircle);
    on<ContributeToCircle>(_onContributeToCircle);
  }

  void _onLoadCircles(LoadCircles event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(CircleLoaded(circles: _circles));
  }

  void _onCreateCircle(CreateCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    final newCircle = Circle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      creator: event.members.first,
      members: event.members,
      contributionAmount: event.contributionAmount,
      roundIndex: 0,
      vaultBalance: 0,
      payoutOrder: event.members,
    );
    
    _circles.add(newCircle);
    emit(CircleLoaded(circles: _circles));
  }

  void _onJoinCircle(JoinCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    final circleIndex = _circles.indexWhere((c) => c.id == event.circleId);
    if (circleIndex != -1) {
      final circle = _circles[circleIndex];
      final updatedMembers = [...circle.members, event.userAddress];
      final updatedCircle = Circle(
        id: circle.id,
        name: circle.name,
        creator: circle.creator,
        members: updatedMembers,
        contributionAmount: circle.contributionAmount,
        roundIndex: circle.roundIndex,
        vaultBalance: circle.vaultBalance,
        payoutOrder: updatedMembers,
      );
      _circles[circleIndex] = updatedCircle;
    }
    
    emit(CircleLoaded(circles: _circles));
  }

  void _onContributeToCircle(ContributeToCircle event, Emitter<CircleState> emit) async {
    emit(CircleLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    final circleIndex = _circles.indexWhere((c) => c.id == event.circleId);
    if (circleIndex != -1) {
      final circle = _circles[circleIndex];
      final updatedCircle = Circle(
        id: circle.id,
        name: circle.name,
        creator: circle.creator,
        members: circle.members,
        contributionAmount: circle.contributionAmount,
        roundIndex: circle.roundIndex,
        vaultBalance: circle.vaultBalance + circle.contributionAmount,
        payoutOrder: circle.payoutOrder,
      );
      _circles[circleIndex] = updatedCircle;
    }
    
    emit(CircleLoaded(circles: _circles));
  }
}
