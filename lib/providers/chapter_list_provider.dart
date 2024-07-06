import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/models/chapter_data.dart';
import 'package:novel_reader/models/models.dart';
import 'package:novel_reader/providers/chapter_data_provider.dart';
import 'package:novel_reader/services/novel_service.dart';

final novelDetailsProvider =
    FutureProvider.family<LightNovel, String>((ref, novelId) async {
  final novelDetails = await NovelService.getNovelInfo(novelId);
  ref
      .read(chapterListProvider.notifier)
      .addChapterListItemsFromJson(novelDetails.chapters);
  ref.read(lightNovelProvider.notifier).setLightNovel(novelDetails);

  return Future.value(novelDetails);
});

final lightNovelProvider =
    StateNotifierProvider<LightNovelNotifier, LightNovel?>(
        (ref) => LightNovelNotifier());

class LightNovelNotifier extends StateNotifier<LightNovel?> {
  LightNovelNotifier() : super(null);

  void setLightNovel(LightNovel lightNovel) {
    state = lightNovel;
  }

  // void updateTitle(String title) {
  //   if (state != null) {
  //     state = LightNovel(
  //       id: state!.id,
  //       title: title,
  //       author: state!.author, genres: [], description: '', status: '', chapters: [],
  //     );
  //   }
  // }

  // void updateContent(String content) {
  //   if (state != null) {
  //     state = LightNovel(
  //       id: state!.id,
  //       title: state!.title,
  //       author: state!.author,
  //       content: content,
  //     );
  //   }
}

class ChapterListNotifier extends StateNotifier<List<ChapterListItem>> {
  ChapterListNotifier() : super([]);

  void addChapterListItemsFromJson(List<Map<String, String>> chapters) {
    state = [
      ...state,
      ...chapters.map(
        (chapter) => ChapterListItem(
            title: chapter['title'] ?? '',
            id: chapter['id'] ?? '',
            url: chapter['url'] ?? ''),
      ),
    ];
  }

  void setChapterListItemsFromJson(List<Map<String, String>> chapters) {
    state = chapters
        .map(
          (chapter) => ChapterListItem(
              title: chapter['title'] ?? '',
              id: chapter['id'] ?? '',
              url: chapter['url'] ?? ''),
        )
        .toList();
  }

  void removeNovelData(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void clearNovelData() {
    state = [];
  }
}

final chapterListProvider =
    StateNotifierProvider<ChapterListNotifier, List<ChapterListItem>>(
  (ref) => ChapterListNotifier(),
);
