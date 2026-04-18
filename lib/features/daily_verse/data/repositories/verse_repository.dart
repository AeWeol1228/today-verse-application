import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verse_model.dart';

class VerseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VerseModel?> getTodayVerse() async {
    final today = _todayKey();
    final doc = await _firestore.collection('daily_verses').doc(today).get();
    if (!doc.exists || doc.data() == null) return null;
    return VerseModel.fromFirestore(doc.data()!);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
