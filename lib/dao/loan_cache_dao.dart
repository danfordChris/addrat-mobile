import 'package:hive_flutter/hive_flutter.dart';
import 'package:pesa_lending/models/loan_cache.dart';

class LoanCacheDao {
  LoanCacheDao._();
  static final LoanCacheDao instance = LoanCacheDao._();

  Box get _box => Hive.box('loan_cache');

  List<LoanCache> getAll() => _box.values
      .map((v) => LoanCache.fromMap(v as Map<dynamic, dynamic>))
      .toList();

  LoanCache? getById(String id) =>
      getAll().where((l) => l.id == id).firstOrNull;

  Future<void> save(LoanCache loan) =>
      _box.put(loan.id, loan.toMap());

  Future<void> clear() => _box.clear();
}
