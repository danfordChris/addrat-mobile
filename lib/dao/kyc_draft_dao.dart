import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pesa_lending/models/kyc_draft_cache.dart';

class KycDraftDao {
  KycDraftDao._();
  static final KycDraftDao instance = KycDraftDao._();

  Box get _box => Hive.box('kyc_draft');

  KycDraftCache? loadDraft() {
    final raw = _box.get('draft');
    if (raw == null) return null;
    return KycDraftCache.fromMap(raw as Map<dynamic, dynamic>);
  }

  Future<void> saveDraft(int step, Map<String, dynamic> data) async {
    final existing = loadDraft();
    final json = jsonEncode(data);
    final draft = KycDraftCache(
      step: step,
      personalInfoJson: step == 0 ? json : existing?.personalInfoJson,
      employmentInfoJson: step == 1 ? json : existing?.employmentInfoJson,
      financialDetailsJson: step == 2 ? json : existing?.financialDetailsJson,
      lastUpdated: DateTime.now(),
    );
    await _box.put('draft', draft.toMap());
  } 

  Future<void> clearDraft() => _box.delete('draft');
}
