import 'package:sui/sui.dart';
import '../models/models.dart';

class SuiClientService {
  late SuiClient _client;
  late Ed25519Keypair _keypair;
  
  static const String _rpcUrl = 'https://fullnode.testnet.sui.io:443';
  static const String _packageId = '0x0'; // Replace with deployed package ID
  
  Future<void> initialize() async {
    _client = SuiClient(_rpcUrl);
    _keypair = Ed25519Keypair.generate();
  }
  
  String get address => _keypair.getPublicKey().toSuiAddress();
  
  Future<String> createCircle(String name, int contributionAmount) async {
    final txb = TransactionBlock();
    txb.moveCall(
      target: '$_packageId::circle::create_circle',
      arguments: [
        txb.pure.string(name),
        txb.pure.u64(contributionAmount),
      ],
    );
    
    final result = await _client.signAndExecuteTransactionBlock(
      signer: _keypair,
      transactionBlock: txb,
    );
    return result.digest;
  }
  
  Future<String> joinCircle(String circleId) async {
    final txb = TransactionBlock();
    txb.moveCall(
      target: '$_packageId::circle::join_circle',
      arguments: [txb.object(circleId)],
    );
    
    final result = await _client.signAndExecuteTransactionBlock(
      signer: _keypair,
      transactionBlock: txb,
    );
    return result.digest;
  }
  
  Future<String> contribute(String vaultId, String circleId, String trustScoreId, int amount) async {
    final txb = TransactionBlock();
    final coin = txb.splitCoins(txb.gas, [txb.pure.u64(amount)]);
    
    txb.moveCall(
      target: '$_packageId::vault::contribute',
      arguments: [
        txb.object(vaultId),
        txb.object(circleId),
        txb.object(trustScoreId),
        coin,
      ],
    );
    
    final result = await _client.signAndExecuteTransactionBlock(
      signer: _keypair,
      transactionBlock: txb,
    );
    return result.digest;
  }
  
  Future<List<Circle>> getUserCircles() async {
    final objects = await _client.getOwnedObjects(address);
    return objects.data
        .where((obj) => obj.data?.type?.contains('circle::Circle') ?? false)
        .map((obj) => Circle.fromSuiObject(obj))
        .toList();
  }
}
