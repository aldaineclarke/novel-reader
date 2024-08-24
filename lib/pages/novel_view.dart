import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:babel_novel/env.dart';
import 'package:babel_novel/hive_adapters/current_novel.dart';
import 'package:babel_novel/models/chapter_data.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:babel_novel/pages/novel_chapter_list.dart';

import 'package:babel_novel/providers/chapter_list_provider.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:babel_novel/providers/preference_provider.dart';
import 'package:babel_novel/providers/shelf_provider.dart';
import 'package:babel_novel/services/novel_service.dart';
import 'package:babel_novel/utils/theme_colors.dart';
import 'package:babel_novel/widgets/novel_panel_options.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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
  final RefreshController _nextChapterController = RefreshController();
  int currentIndex = 1;
  final String hostName = 'AnimeDaily.Net';
  late Box<CurrentNovel> novelBox;
  double _fontSize = 16;
  Color _fontColor = Colors.black;
  Color _backgroundColor = Colors.white;
  bool isPanelVisible = false;

  final testStr =
      'If you find any errors ( Ads popup, ads redirect, broken links, non-standard content, etc.. ), Please let us know < report chapter > so we can fix it as soon as possible.';

  late FlutterTts flutterTts;
  String _text = 'This is a test'; // Combined text

  Future<void> _speak(String speech) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1);
    // Text to speech have a limit with the length of the string 2000
    await flutterTts.speak(speech.substring(0, 4000));
  }

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    currentNovel = super.widget.novelChapter;
    novelBox = Hive.box<CurrentNovel>(Env.novel_db_name);
    final novel = ref.read(currentNovelProvider);
    final novelList = ref.read(chapterListProvider);
    if (kDebugMode) {
      print('chapterLogs: ChapterId -  ${novel?.currentChapterId}');
    }
    currentIndex = novelList.indexWhere((chapterItem) {
      return chapterItem.id == novel?.currentChapterId;
    });
    if (kDebugMode) {
      print('chapterLogs: CurrentIndex - ${currentIndex}');
    }

    novelBox.put('currentNovel', novel!);

    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPageChapterList(String novelId, {int page = 1}) async {
    final novelData = await NovelService.getNovelInfo(novelId, page);
    if (kDebugMode) {
      print(novelData.chapters);
    }
    ref
        .read(chapterListProvider.notifier)
        .addChapterListItemsFromJson(novelData.chapters);
  }

  void _loadNextChapter() {
    // Simulate fetching more items
    final novel = ref.read(currentNovelProvider);
    final chapterList = ref.read(chapterListProvider);
    setState(
      () {
        currentIndex++;
        if (currentIndex == chapterList.length) {
          // novel?.copyWith(currentPage: novel.currentPage + 1);

          fetchPageChapterList(novel!.novelId, page: novel.currentPage + 1)
              .then((value) {
            if (kDebugMode) {
              print(chapterList.length);
              print(chapterList);
            }
            currentNovel = chapterList[currentIndex].id;
            // Copy with not working  correctly
            final updatedNovel = novel?.copyWith(
                currentChapterId: currentNovel,
                currentPage: novel.currentPage + 1);
            novelBox.put('currentNovel', updatedNovel!);
            ref
                .read(shelfProvider.notifier)
                .updateNovelCurrentChapter(updatedNovel);
            ref.read(currentNovelProvider.notifier).setNovel(updatedNovel);
          });
          // Fetch next set of chapterListings then upudate the chapterListProvider.
          // Start off index at 0.
        } else {
          currentNovel = chapterList[currentIndex].id;
          // Copy with not working  correctly
          final updatedNovel = novel?.copyWith(
              currentChapterId: currentNovel,
              currentPage: novel.currentPage + 1);
          novelBox.put('currentNovel', updatedNovel!);
          ref
              .read(shelfProvider.notifier)
              .updateNovelCurrentChapter(updatedNovel);
          ref.read(currentNovelProvider.notifier).setNovel(updatedNovel);
        }
      },
    );
    print('CurrentNovel: $currentNovel ');
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _nextChapterController.refreshCompleted();
  }

  void _onLoad() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _loadNextChapter();
    _nextChapterController.loadComplete();
  }

  void showSnackBar(BuildContext context) {
    const snackBar = SnackBar(
      content: Center(
        child: Text(
          'double tap for settings',
          style: TextStyle(fontSize: 10),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      width: 130,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      duration: Duration(milliseconds: 500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildPanel(BuildContext context, String title) {
    return Material(
      elevation: 5,
      child: Container(
        height: 100, // Adjust the height of the panel
        color: ThemeColors.brown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                // Add any action if needed
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => NovelChapterList(
                      novelId: ref.read(currentNovelProvider)!.novelId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterDataAsyncValue = ref.watch(chapterDataProvider(currentNovel));
    final preferences = ref.watch(preferenceProvider);
    return Scaffold(
      backgroundColor: preferences.backgroundColor,
      body: chapterDataAsyncValue.when(
        data: (data) {
          final chapterData = data;
          final paragraphs = chapterData.text.split('\n');
          // _text = paragraphs.join('\n\n'); // Update combined text

          return Stack(
            children: [
              Positioned(
                child: Scrollbar(
                  child: SmartRefresher(
                    onLoading: _onLoad,
                    enablePullUp: true,
                    enablePullDown: false,
                    controller: _nextChapterController,
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus? mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = const Text('pull up load');
                        } else if (mode == LoadStatus.loading) {
                          body = const CupertinoActivityIndicator();
                        } else if (mode == LoadStatus.failed) {
                          body = const Text('Load Failed!Click retry!');
                        } else if (mode == LoadStatus.canLoading) {
                          body = const Text('release to load more');
                        } else {
                          body = const Text('No more Data');
                        }
                        return SizedBox(
                          height: 55,
                          child: Center(child: body),
                        );
                      },
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onDoubleTap: () {
                            setState(() {
                              isPanelVisible = !isPanelVisible;
                            });
                          },
                          onTap: () {
                            showSnackBar(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 150, bottom: 20),
                                child: Center(
                                  child: parseChapterTitle(
                                    chapterData.chapterTitle,
                                    preferences.fontColor,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style:
                                      TextStyle(color: preferences.fontColor),
                                  children: paragraphs.map((paragraph) {
                                    if (testStr == paragraph ||
                                        paragraph.contains(
                                          chapterData.chapterTitle,
                                        ) ||
                                        paragraph.toLowerCase().trim() ==
                                            chapterData.chapterTitle
                                                .toLowerCase() ||
                                        paragraph
                                            .toLowerCase()
                                            .contains('chapter')) {
                                      return const TextSpan(text: '');
                                    }
                                    if (hostName == paragraph) {
                                      return const TextSpan();
                                    }
                                    return TextSpan(
                                      text: '$paragraph\n\n',
                                      style: TextStyle(
                                        color: preferences.fontColor,
                                        fontSize: preferences.fontSize,
                                        height: preferences.fontSize / 10,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top:
                    isPanelVisible ? 0 : -100, // Adjust the height of the panel
                left: 0,
                right: 0,
                child: _buildPanel(context, chapterData.novelTitle),
              ),
              AnimatedPositioned(
                bottom: isPanelVisible
                    ? 0
                    : -(MediaQuery.of(context).size.height * .4),
                left: 0,
                right: 0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .25,
                  child: const NovelViewOptionPanel(),
                ),
              ),
            ],
          );
        },
        error: (error, stacktrace) => const Text('No Content'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print('test');
      //     _speak(textToSpeech);
      //   },
      //   child: const Icon(Icons.mic_none),
      // ),
    );
  }

  Widget parseChapterTitle(String title, Color color) {
    // Regular expression to match "Chapter <number> - <title>"
    final regExp = RegExp(r'(?:[Cc]hapter)\s+(\d+)(?:\s*[-:]\s*|\s+)(.*)?');

    final match = regExp.firstMatch(title);
    if (match != null) {
      final chapterNumber = int.parse(match.group(1)!);
      final chapterName = match.group(2) ?? '';
      final chapterTitle = chapterName;
      return Column(
        children: [
          Text('Chapter $chapterNumber'),
          const SizedBox(height: 10),
          Text(
            chapterTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }
}

var chapterDataProvider =
    FutureProvider.family<ChapterData, String>((ref, currentNovel) async {
  var currentChapter = await NovelService.getNovelChapter(currentNovel);
  //set text
  // ref.read(textToSpeechProvider.notifier).updateText(currentChapter.text);
  return currentChapter;
});

// var textToSpeechProvider = StateNotifierProvider<TextToSpeechNotifier, String>(
//     (ref) => TextToSpeechNotifier(''));

// class TextToSpeechNotifier extends StateNotifier<String> {
//   TextToSpeechNotifier(super.state);

//   updateText(String text) {
//     state = state + text;
//   }
// }
