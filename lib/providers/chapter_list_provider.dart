import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/models/chapter_data.dart';
import 'package:novel_reader/models/models.dart';
import 'package:novel_reader/services/novel_service.dart';

final novelDetailsProvider =
    FutureProvider.family<LightNovel, String>((ref, novelId) async {
  final novelDetails = await NovelService.getNovelInfo(novelId);
  ref
      .read(chapterListProvider.notifier)
      .addChapterListItemsFromJson(novelDetails.chapters);
  return Future.value(novelDetails);
});

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
