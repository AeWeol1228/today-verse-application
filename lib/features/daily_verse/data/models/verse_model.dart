import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({
    required super.book,
    required super.chapter,
    required super.verse,
    required super.verseText,
    required super.bookDescription,
  });

  factory VerseModel.fromFirestore(Map<String, dynamic> data) {
    return VerseModel(
      book: data['book'] as String,
      chapter: data['chapter'] as int,
      verse: data['verse'] as int,
      verseText: data['verse_text'] as String,
      bookDescription: data['book_description'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'verse_text': verseText,
      'book_description': bookDescription,
    };
  }
}
