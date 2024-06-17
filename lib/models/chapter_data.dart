class ChapterData {
  ChapterData(
      {required this.text,
      required this.chapterTitle,
      required this.novelTitle});

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return ChapterData(
      novelTitle: json['novelTitle'] as String,
      chapterTitle: json['chapterTitle'] as String,
      text: json['text'] as String,
    );
  }
  final String novelTitle;
  final String chapterTitle;
  final String text;
}

class ChapterListItem {
  ChapterListItem({required this.id, required this.title, required this.url});

  factory ChapterListItem.fromJson(Map<String, dynamic> json) {
    return ChapterListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
  final String id;
  final String title;
  final String url;
}
