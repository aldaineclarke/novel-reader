import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_reader/models/chapter_data.dart';
import 'package:novel_reader/pages/novel_view.dart';
import 'package:novel_reader/providers/chapter_list_provider.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';
import 'package:novel_reader/services/novel_service.dart';

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
      for (var i = 0; i < ref.read(lightNovelProvider)!.pages; i++) false
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lightnovel = ref.watch(lightNovelProvider);
// Define a regular expression to match digits
    final regExp = RegExp(r'\d+');
    const pageLimit = 40;

    // Find all matches in the input string
    return Scaffold(
      body: ListView(
        children: [
          ExpansionPanelList(
            // creates an array of items of length pages.
            children:
                [for (var i = 0; i < lightnovel!.pages; i++) i].map((page) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      'Chapter ${page * pageLimit + 1} - Chapter ${page * pageLimit + pageLimit}',
                    ),
                  );
                },
                body: Container(
                  child: FutureBuilder(
                      future:
                          NovelService.getNovelInfo(widget.novelId, page + 1),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Text('No Content');
                        } else {
                          final chapters = snapshot.data!.chapters;
                          //fills thee chapterlist provider with the 40 chapters fetched

                          return Column(
                            children: chapters.map(
                              (chapter) {
                                final chapterData =
                                    ChapterListItem.fromJson(chapter);
                                return ListTile(
                                  onTap: () {
                                    ref
                                        .read(chapterListProvider.notifier)
                                        .setChapterListItemsFromJson(
                                          snapshot.data!.chapters,
                                        );
                                    final novel =
                                        ref.read(currentNovelProvider);
                                    if (kDebugMode) {
                                      print(
                                          'This is novel Description: ${novel?.description}');
                                    }
                                    ref
                                        .read(currentNovelProvider.notifier)
                                        .setNovel(novel!.copyWith(
                                            currentChapterId: chapterData.id));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (context) => NovelView(
                                            novelChapter: chapterData.id),
                                      ),
                                    );
                                  },
                                  title: Text(chapterData.title),
                                );
                              },
                            ).toList(),
                          );
                        }
                      }),
                ),
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
}
