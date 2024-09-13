import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_novel/models/chapter_data.dart';

class ChapterDataNotifier extends StateNotifier<ChapterInfo> {
  ChapterDataNotifier()
      : super(
          ChapterInfo(
            chapterId: '',
            chapterData: ChapterData(
              text: 'hey',
              novelTitle: 'title',
              chapterTitle: 'chapter',
            ),
          ),
        );

  void setCurrentChapterData(ChapterInfo chapterInfo) {
    state = chapterInfo;
  }
}

class ChapterInfo {
  ChapterInfo({required this.chapterData, required this.chapterId});
  ChapterData chapterData;
  String chapterId;
}
