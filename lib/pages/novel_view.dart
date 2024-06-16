import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novel_reader/services/novel_service.dart';

class NovelView extends StatefulWidget {
  const NovelView({required this.novelChapter, super.key});
  static const routeName = 'Read Novel';
  final String novelChapter;

  @override
  State<NovelView> createState() => _NovelViewState();
}

class _NovelViewState extends State<NovelView> {
  final ScrollController _scrollController = ScrollController();

  final testStr =
      'If you find any errors ( Ads popup, ads redirect, broken links, non-standard content, etc.. ), Please let us know < report chapter > so we can fix it as soon as possible.';

  @override
  void initState() {
    super.initState();
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
      future: NovelService.getNovelChapter(widget.novelChapter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('No Content');
        }
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
                      return RichText(
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
