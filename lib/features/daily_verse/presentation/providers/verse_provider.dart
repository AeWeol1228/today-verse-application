import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/verse_model.dart';
import '../../data/repositories/verse_repository.dart';

final verseRepositoryProvider = Provider((_) => VerseRepository());

final todayVerseProvider = FutureProvider<VerseModel?>((ref) {
  return ref.watch(verseRepositoryProvider).getTodayVerse();
});
