import 'package:equatable/equatable.dart';

class Circle extends Equatable {
  final String id;
  final String name;
  final String creator;
  final List<String> members;
  final double contributionAmount;
  final int roundIndex;
  final double vaultBalance;
  final List<String> payoutOrder;

  const Circle({
    required this.id,
    required this.name,
    required this.creator,
    required this.members,
    required this.contributionAmount,
    required this.roundIndex,
    required this.vaultBalance,
    required this.payoutOrder,
  });

  static Circle fromSuiObject(dynamic obj) {
    final fields = obj.data?.content?.fields ?? {};
    return Circle(
      id: obj.data?.objectId ?? '',
      name: fields['name'] ?? '',
      creator: fields['creator'] ?? '',
      members: List<String>.from(fields['members'] ?? []),
      contributionAmount: (fields['contribution_amount'] ?? 0).toDouble(),
      roundIndex: fields['round_index'] ?? 0,
      vaultBalance: 0.0,
      payoutOrder: List<String>.from(fields['payout_order'] ?? []),
    );
  }

  @override
  List<Object> get props => [id, name, creator, members, contributionAmount, roundIndex, vaultBalance, payoutOrder];
}

class User extends Equatable {
  final String id;
  final String address;
  final String name;
  final int trustScore;

  const User({
    required this.id,
    required this.address,
    required this.name,
    required this.trustScore,
  });

  @override
  List<Object> get props => [id, address, name, trustScore];
}

class ContributionRecord extends Equatable {
  final String circleId;
  final String userAddress;
  final int round;
  final bool hasPaid;

  const ContributionRecord({
    required this.circleId,
    required this.userAddress,
    required this.round,
    required this.hasPaid,
  });

  @override
  List<Object> get props => [circleId, userAddress, round, hasPaid];
}
