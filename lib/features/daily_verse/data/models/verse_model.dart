import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({
    required super.book,
    required super.chapter,
    required super.verse,
    required super.verseEnd,
    required super.verseText,
    required super.bookDescription,
    super.bookEn,
    super.audioUrlVerse,
    super.audioUrlDescription,
    super.dateKey,
  });

  factory VerseModel.fromFirestore(Map<String, dynamic> data, {String? dateKey}) {
    return VerseModel(
      book: data['book'] as String,
      chapter: data['chapter'] as int,
      verse: data['verse'] as int,
      verseEnd: data['verse_end'] as int,
      verseText: data['verse_text'] as String,
      bookDescription: data['book_description'] as String,
      bookEn: data['book_en'] as String?,
      audioUrlVerse: data['audio_url_verse'] as String?,
      audioUrlDescription: data['audio_url_description'] as String?,
      dateKey: dateKey,
    );
  }
}
