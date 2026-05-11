import 'package:hive_flutter/hive_flutter.dart';
import 'package:pesa_lending/dao/bank_cache_dao.dart';
import 'package:pesa_lending/dao/kyc_draft_dao.dart';
import 'package:pesa_lending/dao/loan_cache_dao.dart';

class DatabaseManager {
  DatabaseManager._();
  static final DatabaseManager instance = DatabaseManager._();

  KycDraftDao get kycDraft => KycDraftDao.instance;
  LoanCacheDao get loanCache => LoanCacheDao.instance;
  BankCacheDao get bankCache => BankCacheDao.instance;

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox('kyc_draft'),
      Hive.openBox('loan_cache'),
      Hive.openBox('bank_cache'),
    ]);
  }
}
