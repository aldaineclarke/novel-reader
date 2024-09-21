// import 'package:babel_novel/providers/chapter_data_provider.dart';
import 'package:babel_novel/env.dart';
import 'package:babel_novel/hive_adapters/current_novel.dart';
import 'package:babel_novel/models/chapter_data.dart';
import 'package:babel_novel/pages/novel_chapter_list.dart';
import 'package:babel_novel/providers/chapter_list_provider.dart';
import 'package:babel_novel/providers/current_chapter_provider.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:babel_novel/providers/preference_provider.dart';
import 'package:babel_novel/providers/shelf_provider.dart';
import 'package:babel_novel/services/novel_service.dart';
import 'package:babel_novel/widgets/error_display_widget.dart';
import 'package:babel_novel/widgets/novel_panel_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
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
  final PageController _pageViewController = PageController();
  double startPosition = 0;
  bool shouldGoBack = false;
  int currentIndex = 1;
  final String hostName = 'AnimeDaily.Net';
  late Box<CurrentNovel> novelBox;
  double _fontSize = 16;
  Color _fontColor = Colors.black;
  Color _backgroundColor = Colors.white;
  bool isPanelVisible = false;
  List<List<RichText>> pages = [];

  final testStr =
      'If you find any errors ( Ads popup, ads redirect, broken links, non-standard content, etc.. ), Please let us know < report chapter > so we can fix it as soon as possible.';

  @override
  void initState() {
    super.initState();
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
    // _pageViewController.addListener(_checkThenSkipToNextChapter);

    if (kDebugMode) {
      print('chapterLogs: CurrentIndex - ${currentIndex}');
    }

    novelBox.put('currentNovel', novel!);

    // Delay function call until after widget build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndProcessData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageViewController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndProcessData() async {
    final data =
        await ref.read(chapterDataProvider(currentNovel)); // ensure async call
    final isolatedPreference = ref.read(preferenceProvider);
    if (data?.value != null) {
      final chapterData = data.value;
      final paragraphs = chapterData!.text.split('.');

      // Map paragraphs to RichText widgets based on user preferences
      setState(() {
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

        // If horizontal scrolling is enabled, split into pages
        if (isolatedPreference.scrollDirection == ScrollDirection.horizontal) {
          splitIntoPages(richTextItems);
        }
      });
    }
  }

  void _checkThenSkipToNextChapter() {
    print('Position: ${_pageViewController.position.pixels}');
    print('Max: ${_pageViewController.position.maxScrollExtent}');
// Check if the current page is the last page
    if (_pageViewController.position.pixels ==
        _pageViewController.position.maxScrollExtent) {
      // Perform the action when the user reaches the last page
      print('Reached the end of the page view');
      currentIndex++;

      _loadNextChapter();
    }
  }

  Future<void> fetchPageChapterList(String novelId, {int page = 1}) async {
    final novelData = await NovelService.getNovelInfo(novelId, page);
    if (kDebugMode) {
      print(novelData.chapters);
    }
    ref
        .read(chapterListProvider.notifier)
        .setChapterListItemsFromJson(novelData.chapters);
  }

  void _loadNextChapter() {
    // Gets the current novel from the provider.
    final novel = ref.read(currentNovelProvider);
    pages = [];
    // Gets the chapters from the chapterList from the provider.
    final chapterList = ref.read(chapterListProvider);
    setState(
      () {
        if (currentIndex < 0) {
          // means thata for some reason we were not able to find the item in the list
          currentIndex = novel!.chapterList.indexWhere((chapterItem) {
            return chapterItem.id == currentNovel;
          });
        }
        if (currentIndex == chapterList.length) {
          // novel?.copyWith(currentPage: novel.currentPage + 1);

          fetchPageChapterList(novel!.novelId, page: novel.currentPage + 1)
              .then((value) {
            if (kDebugMode) {
              print(chapterList.length);
              print(chapterList);
            }
            currentIndex = 0;
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
    // _fetchAndProcessData();
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
    currentIndex++;

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
      elevation: 1,
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      surfaceTintColor: Theme.of(context).colorScheme.primary,
      child: SizedBox(
        height: 100, // Adjust the height of the panel
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                // size: 40,
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
                    fontSize: 18, overflow: TextOverflow.ellipsis),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
              ),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: preferences.backgroundColor,
        body: chapterDataAsyncValue.when(
          data: (data) {
            final chapterData = data;
            final paragraphs = chapterData.text.split('.');
            // _text = paragraphs.join('\n\n'); // Update combined text
            final richTextItems = paragraphs.map((text) {
              return RichText(
                text: TextSpan(
                  text: '$text\n',
                  style: TextStyle(
                    color: preferences.fontColor,
                    fontSize: preferences.fontSize,
                    height: preferences.fontSize / 10,
                  ),
                ),
              );
            }).toList();
            return Stack(
              children: [
                Positioned(
                  child: GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        isPanelVisible = !isPanelVisible;
                      });
                    },
                    onHorizontalDragStart: (details) {
                      // set the start position
                      startPosition = details.globalPosition.dx;
                    },
                    onHorizontalDragUpdate: (details) {
                      // compare the start position with the current position
                      // set state to determine if I should reload or not.
                      if (startPosition > details.globalPosition.dx) {
                        shouldGoBack = false;
                      } else if (startPosition < details.globalPosition.dx) {
                        shouldGoBack = true;
                      }
                      setState(() {});
                    },
                    onHorizontalDragEnd: (details) {
                      // based on the state which hold if user swipes right.
                      print(shouldGoBack);
                      // Call the previous chapter function
                      if (shouldGoBack) {
                        currentIndex -= 1;
                      } else if (shouldGoBack == false) {
                        currentIndex += 1;
                      }
                      _loadNextChapter();
                    },
                    onTap: () {
                      showSnackBar(context);
                    },
                    child:
                        preferences.scrollDirection == ScrollDirection.vertical
                            ? showScrollView(
                                chapterData,
                                preferences,
                                paragraphs,
                              )
                            : showPageView(
                                chapterData,
                                preferences,
                                paragraphs,
                              ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  top: isPanelVisible
                      ? 0
                      : -100, // Adjust the height of the panel
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
                    height: MediaQuery.of(context).size.height * .4,
                    child: const NovelViewOptionPanel(),
                  ),
                ),
              ],
            );
          },
          error: (error, stacktrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ErrorDisplayWidget(
                    message: 'Not able to view novel chapter right now',
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Refetch the data by triggering the provider
                      ref
                          .read(chapterDataProvider(currentNovel).notifier)
                          .fetchChapterDetails();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget showScrollView(ChapterData chapterData,
      PreferencesProvider preferences, List<String> paragraphs) {
    return Scrollbar(
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 150, bottom: 20),
                  child: Center(
                    child: parseChapterTitle(
                      chapterData.chapterTitle,
                      preferences.fontColor,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: preferences.fontColor),
                    children: paragraphs.map((paragraph) {
                      if (testStr == paragraph ||
                          paragraph.contains(
                            chapterData.chapterTitle,
                          ) ||
                          paragraph.toLowerCase().trim() ==
                              chapterData.chapterTitle.toLowerCase() ||
                          paragraph.toLowerCase().contains('chapter')) {
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
            );
          },
        ),
      ),
    );
  }

  Widget showPageView(ChapterData chapterData, PreferencesProvider preferences,
      List<String> paragraph) {
    pages = ref
        .read(chapterDataProvider(currentNovel).notifier)
        .splitChaptersIntoPages(MediaQuery.of(context).size.height * .9,
            MediaQuery.of(context).size.width);
    return PageView.builder(
      itemCount: pages.length + 1,
      controller: _pageViewController,
      allowImplicitScrolling: true,
      onPageChanged: (value) {
        print('value : $value');
        print('Total Pages : ${pages.length}');
        // Check if the user has reached the last page
        if (value == pages.length) {
          // Prevent looping by jumping to the next chapter or triggering method
          currentIndex++;

          _loadNextChapter(); // Method to call when the user reaches the last page
        }
      },
      itemBuilder: (context, index) {
        if (index == pages.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pages[index],
            ),
          ),
        );
      },
    );
  }

  // Function to split RichText items into pages
  void splitIntoPages(List<RichText> richTextItems) {
    final availableHeight = MediaQuery.of(context).size.height * .9;
    double currentHeight = 0;
    List<RichText> currentPage = [];

    for (var richText in richTextItems) {
      final span = richText.text as TextSpan;
      final painter = TextPainter(
        text: span,
        maxLines: null,
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: MediaQuery.of(context).size.width);

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

    setState(() {
      // isLoading = false;
    });
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
          Text(
            'Chapter $chapterNumber',
            style: TextStyle(color: color),
          ),
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

// var textToSpeechProvider = StateNotifierProvider<TextToSpeechNotifier, String>(
//     (ref) => TextToSpeechNotifier(''));

// class TextToSpeechNotifier extends StateNotifier<String> {
//   TextToSpeechNotifier(super.state);

//   updateText(String text) {
//     state = state + text;
//   }
// }
