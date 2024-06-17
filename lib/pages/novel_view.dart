import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/providers/chapter_list_provider.dart';
import 'package:novel_reader/services/novel_service.dart';

class NovelView extends ConsumerStatefulWidget {
  const NovelView({required this.novelChapter, super.key});
  static const routeName = 'Read Novel';
  final String novelChapter;

  @override
  ConsumerState<NovelView> createState() => _NovelViewState();
}

class _NovelViewState extends ConsumerState<NovelView> {
  final ScrollController _scrollController = ScrollController();
  late String currentNovel;
  int currentIndex = 1;

  final testStr =
      'If you find any errors ( Ads popup, ads redirect, broken links, non-standard content, etc.. ), Please let us know < report chapter > so we can fix it as soon as possible.';

  @override
  void initState() {
    super.initState();
    print('in init state');
    currentNovel = super.widget.novelChapter;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      bool isBottom = _scrollController.position.pixels != 0;
      print('This : ${_scrollController.position.pixels}');
      if (isBottom) {
        // _loadMoreItems();
        print('at bottom');
      }
    }
  }

  void _loadMoreItems() {
    // Simulate fetching more items
    setState(() {
      // _items.addAll(List.generate(20, (index) => _items.length + index));
    });
  }

  @override
  Widget build(BuildContext context) {
    print('ChapterID: ${widget.novelChapter}');

    return FutureBuilder(
      future: NovelService.getNovelChapter(currentNovel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('No Content');
        }
        final val = ref.read(chapterListProvider);
        return Scaffold(
          backgroundColor: Colors.amber[50],
          body: Stack(
            children: [
              Positioned(
                child: Scrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      final paragraphs = snapshot.data!.text.split('\n');
                      return Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: paragraphs.map((paragraph) {
                                if (testStr == paragraph) {
                                  return TextSpan(text: '');
                                }
                                return TextSpan(
                                  text: '$paragraph\n\n',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    final novelList =
                                        ref.read(chapterListProvider);

                                    setState(
                                      () {
                                        currentNovel =
                                            novelList[currentIndex].id;
                                        print(currentNovel);
                                        currentIndex++;
                                      },
                                    );
                                  },
                                  child: Text('hey'))
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
