import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verse_model.dart';

class VerseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 6시 이전이면 전날을 "오늘"로 취급
  DateTime _effectiveToday() {
    final now = DateTime.now();
    return now.hour < 6 ? now.subtract(const Duration(days: 1)) : now;
  }

  Future<VerseModel?> getTodayVerse() async {
    final effective = _effectiveToday();
    final todayDoc = await _firestore
        .collection('daily_verses')
        .doc(_dateKey(effective))
        .get();
    if (todayDoc.exists && todayDoc.data() != null) {
      return VerseModel.fromFirestore(todayDoc.data()!);
    }

    final yesterdayDoc = await _firestore
        .collection('daily_verses')
        .doc(_dateKey(effective.subtract(const Duration(days: 1))))
        .get();
    if (!yesterdayDoc.exists || yesterdayDoc.data() == null) return null;
    return VerseModel.fromFirestore(yesterdayDoc.data()!);
  }

  Future<List<VerseModel>> getRecentVerses({int limit = 30}) async {
    final snap = await _firestore
        .collection('daily_verses')
        .get();
    final today = _dateKey(_effectiveToday());
    final result = <VerseModel>[];
    for (final d in snap.docs) {
      if (d.id.compareTo(today) > 0) continue;
      if (d.data().isEmpty) continue;
      try {
        result.add(VerseModel.fromFirestore(d.data(), dateKey: d.id));
      } catch (e) {
        // ignore malformed documents
      }
    }
    result.sort((a, b) => (b.dateKey ?? '').compareTo(a.dateKey ?? ''));
    return result.take(limit).toList();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
