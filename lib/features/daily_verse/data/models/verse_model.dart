import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({
    required super.book,
    required super.chapter,
    required super.verse,
    required super.verseEnd,
    required super.verseText,
    required super.bookDescription,
    super.audioUrl,
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
      audioUrl: data['audio_url'] as String?,
      dateKey: dateKey,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'verse_end': verseEnd,
      'verse_text': verseText,
      'book_description': bookDescription,
    };
  }
}
