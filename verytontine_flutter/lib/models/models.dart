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
    try {
      final data = obj['data'];
      final fields = data?['content']?['fields'] ?? {};
      return Circle(
        id: data?['objectId'] ?? '',
        name: fields['name'] ?? 'Unknown Circle',
        creator: fields['creator'] ?? '',
        members: List<String>.from(fields['members'] ?? []),
        contributionAmount: double.tryParse(fields['contribution_amount']?.toString() ?? '0') ?? 0.0,
        roundIndex: int.tryParse(fields['round_index']?.toString() ?? '0') ?? 0,
        vaultBalance: 0.0, // Will be fetched separately
        payoutOrder: List<String>.from(fields['payout_order'] ?? []),
      );
    } catch (e) {
      return Circle(
        id: '',
        name: 'Error Loading Circle',
        creator: '',
        members: [],
        contributionAmount: 0.0,
        roundIndex: 0,
        vaultBalance: 0.0,
        payoutOrder: [],
      );
    }
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
    this.trustScore = 0,
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
