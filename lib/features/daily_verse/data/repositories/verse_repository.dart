import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verse_model.dart';

class VerseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VerseModel?> getTodayVerse() async {
    final todayDoc = await _firestore
        .collection('daily_verses')
        .doc(_dateKey(DateTime.now()))
        .get();
    if (todayDoc.exists && todayDoc.data() != null) {
      return VerseModel.fromFirestore(todayDoc.data()!);
    }

    final yesterdayDoc = await _firestore
        .collection('daily_verses')
        .doc(_dateKey(DateTime.now().subtract(const Duration(days: 1))))
        .get();
    if (!yesterdayDoc.exists || yesterdayDoc.data() == null) return null;
    return VerseModel.fromFirestore(yesterdayDoc.data()!);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
