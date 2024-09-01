import 'package:babel_novel/models/light_novel.dart';
import 'package:babel_novel/services/novel_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NovelDetailsStateNotifier extends StateNotifier<AsyncValue<LightNovel>> {
  NovelDetailsStateNotifier(this._novelId) : super(const AsyncValue.loading());

  final String _novelId;

  Future<void> fetchNovelDetails() async {
    try {
      state = const AsyncValue.loading();
      final novelDetails = await NovelService.getNovelInfo(_novelId);
      state = AsyncValue.data(novelDetails);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

final novelDetailsProvider = StateNotifierProvider.family<
    NovelDetailsStateNotifier, AsyncValue<LightNovel>, String>(
  (ref, novelId) => NovelDetailsStateNotifier(novelId)..fetchNovelDetails(),
);
