import 'package:hive/hive.dart';
import 'package:babel_novel/providers/chapter_data_provider.dart';

import 'chapter_list_item.dart';

part 'current_novel.g.dart';

@HiveType(typeId: 0)
class CurrentNovel {
  CurrentNovel({
    required this.novelTitle,
    required this.novelId,
    required this.novelImage,
    required this.genres,
    required this.author,
    required this.description,
    required this.currentChapterId,
    required this.chapterCount,
    required this.currentPage,
    required this.chapterList,
  });

  factory CurrentNovel.fromJson(Map<String, dynamic> json) {
    return CurrentNovel(
      novelImage: json['image'] as String,
      novelTitle: json['title'] as String,
      novelId: json['novelId'] as String,
      genres: List<String>.from(json['genres'] as List),
      currentChapterId: json['currentChapterId'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      chapterCount: json['chapterCount'] as int,
      currentPage: json['currentPage'] != null ? json['currentPage'] as int : 1,
      chapterList: json['chapterList'] as List<ChapterListItem>,
    );
  }
  CurrentNovel copyWith({
    String? novelTitle,
    String? novelId,
    String? novelImage,
    List<String>? genres,
    String? currentChapterId,
    String? author,
    String? description,
    int? chapterCount,
    int? currentPage,
    List<ChapterListItem>? chapterList,
  }) {
    return CurrentNovel(
        novelTitle: novelTitle ?? this.novelTitle,
        novelId: novelId ?? this.novelId,
        novelImage: novelImage ?? this.novelImage,
        genres: genres ?? this.genres,
        author: author ?? this.author,
        description: description ?? this.description,
        currentChapterId: currentChapterId ?? this.currentChapterId,
        chapterCount: chapterCount ?? this.chapterCount,
        currentPage: currentPage ?? this.currentPage,
        chapterList: chapterList ?? this.chapterList);
  }

  @HiveField(0)
  final String novelTitle;

  @HiveField(1)
  final String novelId;

  @HiveField(2)
  final String novelImage;

  @HiveField(3)
  final List<String> genres;

  @HiveField(4)
  final String author;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String currentChapterId;

  @HiveField(7)
  final int chapterCount;

  @HiveField(8)
  final int currentPage;

  @HiveField(9)
  final List<ChapterListItem> chapterList;
}
