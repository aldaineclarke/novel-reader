import 'package:babel_novel/models/chapter_data.dart';
import 'package:babel_novel/providers/preference_provider.dart';
import 'package:babel_novel/services/novel_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  List<List<RichText>> splitChaptersIntoPages(
      double pageHeight, double pageWidth) {
    final isolatedPreference = _ref.read(preferenceProvider);
    if (state.value != null) {
      final chapterData = state.value;
      final paragraphs = chapterData!.text.split('.');
      if (kDebugMode) {
        print('shows how much splitChapters is called');
      }
      // Map paragraphs to RichText widgets based on user preferences
      final richTextItems = paragraphs.map((text) {
        return RichText(
          text: TextSpan(
            text: '$text\n',
            style: TextStyle(
              color: isolatedPreference.fontColor,
              fontSize: isolatedPreference.fontSize,
              height: isolatedPreference.fontSize / 10,
            ),
          ),
        );
      }).toList();

      final availableHeight = pageHeight * .9;
      final List<List<RichText>> pages = [];
      double currentHeight = 0;
      List<RichText> currentPage = [];

      for (var richText in richTextItems) {
        final span = richText.text as TextSpan;
        final painter = TextPainter(
          text: span,
          maxLines: null,
          textDirection: TextDirection.ltr,
        );
        painter.layout(maxWidth: pageWidth.toDouble());

        double textHeight = painter.height;

        if (currentHeight + textHeight <= availableHeight) {
          currentPage.add(richText);
          currentHeight += textHeight;
        } else {
          pages.add(currentPage);
          currentPage = [richText];
          currentHeight = textHeight;
        }
      }

      if (currentPage.isNotEmpty) {
        pages.add(currentPage);
      }
      return pages;
    }
    return [];
  }
}

class ChapterDataPagesStateNotifier
    extends StateNotifier<AsyncValue<ChapterData>> {
  ChapterDataPagesStateNotifier(this._chapterId, this._ref)
      : super(const AsyncValue.loading()) {
    fetchChapterDetails(0, 0);
  }

  final String _chapterId;
  final Ref _ref;

  Future<void> fetchChapterDetails(int pageHeight, int pageWidth) async {
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

final totalNovelPages = StateProvider<int>((ref) => 0);
