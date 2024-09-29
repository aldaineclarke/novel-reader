import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:babel_novel/models/chapter_data.dart';
import 'package:babel_novel/pages/novel_view.dart';
import 'package:babel_novel/providers/chapter_list_provider.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:babel_novel/providers/shelf_provider.dart';
import 'package:babel_novel/services/novel_service.dart';

class NovelChapterList extends ConsumerStatefulWidget {
  const NovelChapterList({required this.novelId, super.key});
  final String novelId;
  static const routeName = 'Novel Chapter List';

  @override
  ConsumerState<NovelChapterList> createState() => _NovelChapterListState();
}

class _NovelChapterListState extends ConsumerState<NovelChapterList> {
  List<bool> isOpen = [];

  @override
  void initState() {
    // TODO: implement initState
    isOpen = [
      for (var i = 0; i < (ref.read(lightNovelProvider)?.pages ?? 0); i++) false
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lightnovel = ref.watch(lightNovelProvider);
    final currentNovel = ref.watch(currentNovelProvider);
// Define a regular expression to match digits
    final regExp = RegExp(r'\d+');
    const pageLimit = 100;

    // Find all matches in the input string
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ExpansionPanelList(
            // creates an array of items of length pages.
            children: [
              for (var i = 0; i < (lightnovel!.chapters.length / 100 ?? 0); i++)
                i
            ].map((page) {
              final start = page * pageLimit;
              final end = page * pageLimit + pageLimit;
              return ExpansionPanel(
                canTapOnHeader: true,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      'Chapter ${page * pageLimit + 1} - Chapter ${page * pageLimit + pageLimit}',
                    ),
                  );
                },
                body: isOpen[page]
                    ? showChapterList(lightnovel!.chapters
                        .map(ChapterListItem.fromJson)
                        .toList()
                        .sublist(start,
                            lightnovel!.chapters.length < end ? null : end))
                    : const SizedBox(),
                isExpanded: isOpen[page],
              );
            }).toList(),
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                isOpen[panelIndex] = isExpanded;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget showChapterList(List<ChapterListItem> chapters) {
    //fills thee chapterlist provider with the 40 chapters fetched

    return Column(
      children: chapters.map(
        (chapter) {
          final chapterData = chapter;
          return ListTile(
            onTap: () {
              final novel = ref.read(currentNovelProvider);
              final updateNovel = novel!.copyWith(
                currentChapterId: chapterData.id,
              );

              /// currentNovelProvider is set when the User reads a chapter of a novel..we can change it to when they view the novel details page for simplicity
              ref.read(currentNovelProvider.notifier).setNovel(updateNovel);
              ref.read(shelfProvider.notifier).updateNovelDetails(
                    updateNovel,
                  );
              if (kDebugMode) {
                print(
                    'chapterLogs: Chapter currentChap -  ${novel.currentChapterId}');
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => NovelView(
                    novelChapter: chapterData.id,
                  ),
                ),
              );
            },
            title: Text(chapterData.title),
          );
        },
      ).toList(),
    );
  }
}
