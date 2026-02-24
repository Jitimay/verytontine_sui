import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class SuiClientService {
  static const String _rpcUrl = 'https://fullnode.testnet.sui.io:443';
  static const String _packageId = '0xc7f0db7397eb5b9adf0369b9da49bd9102c532ead2015a4f0dc4b30f28578199';
  
  String? _userAddress;
  
  void setUserAddress(String address) {
    _userAddress = address;
  }
  
  String get userAddress => _userAddress ?? '';
  
  Future<Map<String, dynamic>> _rpcCall(String method, List<dynamic> params) async {
    final response = await http.post(
      Uri.parse(_rpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': method,
        'params': params,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('RPC call failed: ${response.statusCode}');
    }
    
    final data = jsonDecode(response.body);
    if (data['error'] != null) {
      throw Exception('RPC error: ${data['error']['message']}');
    }
    
    return data['result'];
  }
  
  Future<List<Circle>> getUserCircles() async {
    if (_userAddress == null) return [];
    
    try {
      final result = await _rpcCall('suix_getOwnedObjects', [
        _userAddress,
        {
          'filter': {
            'StructType': '$_packageId::circle::Circle'
          },
          'options': {
            'showContent': true,
            'showType': true,
          }
        }
      ]);
      
      final objects = result['data'] as List;
      return objects.map((obj) => Circle.fromSuiObject(obj)).toList();
    } catch (e) {
      print('Error fetching circles: $e');
      return [];
    }
  }
  
  Future<String> createCircle(String name, int contributionAmount) async {
    if (_userAddress == null) throw Exception('User not authenticated');
    
    final txBytes = await _buildTransaction([
      {
        'MoveCall': {
          'package': _packageId,
          'module': 'circle',
          'function': 'create_circle',
          'arguments': [name, contributionAmount.toString()],
        }
      }
    ]);
    
    // Return transaction bytes for signing
    return txBytes;
  }
  
  Future<String> joinCircle(String circleId) async {
    if (_userAddress == null) throw Exception('User not authenticated');
    
    final txBytes = await _buildTransaction([
      {
        'MoveCall': {
          'package': _packageId,
          'module': 'circle',
          'function': 'join_circle',
          'arguments': [circleId],
        }
      }
    ]);
    
    return txBytes;
  }
  
  Future<String> createVault(String circleId) async {
    if (_userAddress == null) throw Exception('User not authenticated');
    
    final txBytes = await _buildTransaction([
      {
        'MoveCall': {
          'package': _packageId,
          'module': 'vault',
          'function': 'create_vault',
          'arguments': [circleId],
        }
      }
    ]);
    
    return txBytes;
  }
  
  Future<String> initializeTrustScore() async {
    if (_userAddress == null) throw Exception('User not authenticated');
    
    final txBytes = await _buildTransaction([
      {
        'MoveCall': {
          'package': _packageId,
          'module': 'trust_score',
          'function': 'initialize_trust_score',
          'arguments': [],
        }
      }
    ]);
    
    return txBytes;
  }
  
  Future<String> contribute(String vaultId, String circleId, String trustScoreId, int amount) async {
    if (_userAddress == null) throw Exception('User not authenticated');
    
    // Get gas coins for payment
    final gasCoins = await _getGasCoins(amount);
    if (gasCoins.isEmpty) throw Exception('Insufficient SUI balance');
    
    final txBytes = await _buildTransaction([
      {
        'SplitCoins': [
          gasCoins.first,
          [amount.toString()]
        ]
      },
      {
        'MoveCall': {
          'package': _packageId,
          'module': 'vault',
          'function': 'contribute',
          'arguments': [vaultId, circleId, trustScoreId, 'Result(0)'],
        }
      }
    ]);
    
    return txBytes;
  }
  
  Future<String> executePayout(String vaultId, String circleId) async {
    if (_userAddress == null) throw Exception('User not authenticated');
    
    final txBytes = await _buildTransaction([
      {
        'MoveCall': {
          'package': _packageId,
          'module': 'vault',
          'function': 'execute_payout',
          'arguments': [vaultId, circleId],
        }
      }
    ]);
    
    return txBytes;
  }
  
  Future<String> _buildTransaction(List<Map<String, dynamic>> commands) async {
    final result = await _rpcCall('unsafe_moveCall', [
      _userAddress,
      commands,
    ]);
    
    return result['txBytes'];
  }
  
  Future<List<String>> _getGasCoins(int minAmount) async {
    final result = await _rpcCall('suix_getCoins', [
      _userAddress,
      '0x2::sui::SUI',
      null,
      null
    ]);
    
    final coins = result['data'] as List;
    return coins
        .where((coin) => int.parse(coin['balance']) >= minAmount)
        .map((coin) => coin['coinObjectId'] as String)
        .toList();
  }
  
  Future<Map<String, dynamic>> executeTransaction(String txBytes, String signature) async {
    final result = await _rpcCall('sui_executeTransactionBlock', [
      txBytes,
      [signature],
      {
        'showInput': true,
        'showRawInput': false,
        'showEffects': true,
        'showEvents': true,
        'showObjectChanges': true,
        'showBalanceChanges': true,
      },
      'WaitForLocalExecution'
    ]);
    
    return result;
  }
  
  Future<int> getUserTrustScore() async {
    if (_userAddress == null) return 0;
    
    try {
      final result = await _rpcCall('suix_getOwnedObjects', [
        _userAddress,
        {
          'filter': {
            'StructType': '$_packageId::trust_score::TrustScore'
          },
          'options': {
            'showContent': true,
          }
        }
      ]);
      
      final objects = result['data'] as List;
      if (objects.isEmpty) return 0;
      
      final trustScore = objects.first['data']['content']['fields']['score'];
      return int.tryParse(trustScore.toString()) ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  Future<double> getVaultBalance(String vaultId) async {
    try {
      final result = await _rpcCall('sui_getObject', [
        vaultId,
        {
          'showContent': true,
        }
      ]);
      
      final balance = result['data']['content']['fields']['balance'];
      return double.tryParse(balance.toString()) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
  
  Future<List<String>> getCircleVaults(String circleId) async {
    try {
      final result = await _rpcCall('suix_queryEvents', [
        {
          'MoveEventType': '$_packageId::vault::VaultCreated'
        },
        null,
        10,
        false
      ]);
      
      final events = result['data'] as List;
      return events
          .where((event) => event['parsedJson']['circle_id'] == circleId)
          .map((event) => event['parsedJson']['vault_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
