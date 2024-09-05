import 'package:babel_novel/models/light_novel.dart';
import 'package:babel_novel/providers/chapter_list_provider.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:babel_novel/providers/shelf_provider.dart';
import 'package:babel_novel/services/novel_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NovelDetailsStateNotifier extends StateNotifier<AsyncValue<LightNovel>> {
  NovelDetailsStateNotifier(this._novelId, this._ref)
      : super(const AsyncValue.loading()) {
    fetchNovelDetails();
  }

  final String _novelId;
  final Ref _ref;

  Future<void> fetchNovelDetails() async {
    try {
      state = const AsyncValue.loading();
      final novelDetails = await NovelService.getNovelInfo(_novelId);

      // Update chapter list and light novel states
      final currentNovel = _ref.read(currentNovelProvider);
      final shelf = _ref.read(shelfProvider.notifier);

      if (currentNovel != null && shelf.novelInShelf(currentNovel)) {
        final novel = _ref
            .read(shelfProvider)
            .firstWhere((element) => element.novelId == currentNovel.novelId);

        _ref
            .read(chapterListProvider.notifier)
            .setChapterListItem(currentNovel.chapterList);
      }

      // _ref
      //     .read(chapterListProvider.notifier)
      //     .addChapterListItemsFromJson(novelDetails.chapters);
      _ref.read(lightNovelProvider.notifier).setLightNovel(novelDetails);

      // Finally, set the state with fetched details
      state = AsyncValue.data(novelDetails);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

final novelDetailsProvider = StateNotifierProvider.family<
    NovelDetailsStateNotifier, AsyncValue<LightNovel>, String>(
  (ref, novelId) {
    return NovelDetailsStateNotifier(novelId, ref);
  },
);
