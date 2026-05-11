import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pesa_lending/models/reference_models.dart';
import 'package:pesa_lending/models/bank_cache.dart';

class BankCacheDao {
  BankCacheDao._();
  static final BankCacheDao instance = BankCacheDao._();

  Box get _box => Hive.box('bank_cache');

  List<BankModel>? getCachedBanks() {
    final raw = _box.get('banks');
    if (raw == null) return null;
    final cache = BankCache.fromMap(raw as Map<dynamic, dynamic>);
    if (cache.isStale) return null;
    final list = jsonDecode(cache.branchesJson) as List;
    return list.map((e) => BankModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBanks(List<BankModel> banks) async {
    final cache = BankCache(
      branchesJson: jsonEncode(banks.map((b) => {'id': b.id, 'name': b.name, 'code': b.code}).toList()),
      cachedAt: DateTime.now(),
    );
    await _box.put('banks', cache.toMap());
  }

  Future<void> clear() => _box.clear();
}
