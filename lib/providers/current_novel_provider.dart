// I need novel id image, genres, currentChapterId chapterCount

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';

// class CurrentNovel {
//   const CurrentNovel({
//     required this.novelTitle,
//     required this.novelId,
//     required this.novelImage,
//     required this.genres,
//     required this.author,
//     required this.description,
//     required this.currentChapterId,
//     required this.chapterCount,
//   });

//   factory CurrentNovel.fromJson(Map<String, dynamic> json) {
//     return CurrentNovel(
//       novelImage: json['image'] as String,
//       novelTitle: json['title'] as String,
//       novelId: json['novelId'] as String,
//       genres: json['genres'] as List<String>,
//       currentChapterId: json['currentChapterId'] as String,
//       description: json['description'] as String,
//       author: json['author'] as String,
//       chapterCount: json['chapterCount'] as int,
//     );
//   }
//   final String novelTitle;
//   final String novelId;
//   final String novelImage;
//   final String author;
//   final String description;
//   final List<String> genres;
//   final String currentChapterId;
//   final int chapterCount;

//   CurrentNovel copyWith({
//     String? novelTitle,
//     String? novelId,
//     String? novelImage,
//     List<String>? genres,
//     String? currentChapterId,
//     String? author,
//     String? description,
//     int? chapterCount,
//   }) {
//     return CurrentNovel(
//       novelTitle: novelTitle ?? this.novelTitle,
//       novelId: novelId ?? this.novelId,
//       novelImage: novelImage ?? this.novelImage,
//       genres: genres ?? this.genres,
//       author: author ?? this.author,
//       description: description ?? this.description,
//       currentChapterId: currentChapterId ?? this.currentChapterId,
//       chapterCount: chapterCount ?? this.chapterCount,
//     );
//   }
// }

// StateNotifier class
class CurrentNovelNotifier extends StateNotifier<CurrentNovel?> {
  CurrentNovelNotifier() : super(null);

  void setNovel(CurrentNovel novel) {
    state = novel;
  }

  void updateNovel({
    String? novelTitle,
    String? novelId,
    String? novelImage,
    List<String>? genres,
    String? currentChapterId,
    int? chapterCount,
  }) {
    if (state != null) {
      state = state!.copyWith(
        novelTitle: novelTitle,
        novelId: novelId,
        novelImage: novelImage,
        genres: genres,
        currentChapterId: currentChapterId,
        chapterCount: chapterCount,
      );
    }
  }

  void clearNovel() {
    state = null;
  }
}

// Provider for the CurrentNovelNotifier
final currentNovelProvider =
    StateNotifierProvider<CurrentNovelNotifier, CurrentNovel?>((ref) {
  return CurrentNovelNotifier();
});
