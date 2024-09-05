import 'package:babel_novel/models/chapter_data.dart';
import 'package:babel_novel/services/novel_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChapterDataStateNotifier extends StateNotifier<AsyncValue<ChapterData>> {
  ChapterDataStateNotifier(this._chapterId, this._ref)
      : super(const AsyncValue.loading()) {
    fetchChapterDetails();
  }

  final String _chapterId;
  final Ref _ref;

  Future<void> fetchChapterDetails() async {
    try {
      state = const AsyncValue.loading();
      final chapterDetails = await NovelService.getNovelChapter(_chapterId);
      // Finally, set the state with fetched details
      state = AsyncValue.data(chapterDetails);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

final chapterDataProvider = StateNotifierProvider.family<
    ChapterDataStateNotifier,
    AsyncValue<ChapterData>,
    String>((ref, chapterId) {
  //set text
  return ChapterDataStateNotifier(chapterId, ref);
});
