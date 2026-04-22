class Verse {
  final String book;
  final int chapter;
  final int verse;
  final int verseEnd;
  final String verseText;
  final String bookDescription;
  final String? audioUrl;

  const Verse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.verseEnd,
    required this.verseText,
    required this.bookDescription,
    this.audioUrl,
  });

  String get reference => '$book $chapter:$verse-$verseEnd';
}
