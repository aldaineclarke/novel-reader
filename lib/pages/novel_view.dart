import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:novel_reader/env.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';
import 'package:novel_reader/models/chapter_data.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:novel_reader/providers/chapter_list_provider.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';
import 'package:novel_reader/providers/shelf_provider.dart';
import 'package:novel_reader/services/novel_service.dart';
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
      print(novel?.currentChapterId);
    }
    currentIndex = novelList.indexWhere((chapterItem) {
      return chapterItem.id == novel?.currentChapterId;
    });

    novelBox.put('currentNovel', novel!);

    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNextChapter() {
    // Simulate fetching more items
    final novel = ref.read(currentNovelProvider);
    final novelList = ref.read(chapterListProvider);

    setState(
      () {
        currentIndex++;
        currentNovel = novelList[currentIndex].id;
        novel?.copyWith(currentChapterId: currentNovel);
        novelBox.put('currentNovel', novel!);
        ref.read(shelfProvider.notifier).updateNovelCurrentChapter(novel);
        ref.read(currentNovelProvider.notifier).setNovel(novel);
      },
    );
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
      backgroundColor: Color.fromARGB(215, 22, 24, 24),
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

  @override
  Widget build(BuildContext context) {
    final chapterDataAsyncValue = ref.watch(chapterDataProvider(currentNovel));
    final textToSpeech = ref.watch(textToSpeechProvider);
    return Scaffold(
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
                            showModalBottomSheet<void>(
                              backgroundColor: Colors.white,
                              context: context,
                              builder: (BuildContext context) {
                                return const NovelViewOptionPanel();
                              },
                            );
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
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
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
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        height: 1.6,
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
            ],
          );
        },
        error: (error, stacktrace) => const Text('No Content'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('test');
          _speak(textToSpeech);
        },
        child: const Icon(Icons.mic_none),
      ),
    );
  }

  Widget parseChapterTitle(String title) {
    // Regular expression to match "Chapter <number> - <title>"
    final regExp = RegExp(r'(?:[Cc]hapter)\s+(\d+)(?:\s*[-:]\s*|\s+)(.*)?');

    final match = regExp.firstMatch(title);
    if (match != null) {
      final chapterNumber = int.parse(match.group(1)!);
      final chapterName = match.group(2) ?? '';
      final chapterTitle = chapterName.split('-').last;
      return Column(
        children: [
          Text('Chapter $chapterNumber'),
          const SizedBox(height: 10),
          Text(
            chapterTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class NovelViewOptionPanel extends StatefulWidget {
  const NovelViewOptionPanel({super.key});

  @override
  State<NovelViewOptionPanel> createState() => _NovelViewOptionPanelState();
}

class _NovelViewOptionPanelState extends State<NovelViewOptionPanel> {
  double _currentSliderValue = 20;
  static const brightnessChannel = MethodChannel('brightnessPlatform');

  String data = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Text(
            'Brightness',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              const Icon(
                Icons.brightness_1,
                size: 8,
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(trackHeight: 1),
                  child: Slider(
                    divisions: 100,
                    min: 0,
                    max: 10,
                    value: 8,
                    onChanged: (value) {},
                  ),
                ),
              ),
              const Icon(Icons.brightness_high, size: 16)
            ],
          ),
          const SizedBox(height: 20),
          Text('Background Color',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Chip(
                label: Text('White'),
                backgroundColor: Colors.white,
                side: BorderSide.none,
              ),
              Chip(
                label: const Text('Yellow'),
                backgroundColor: Colors.amber[50],
                side: BorderSide.none,
              ),
              const Chip(
                label: Text(
                  'Black',
                  style: TextStyle(color: Colors.white70),
                ),
                backgroundColor: Colors.black,
                side: BorderSide.none,
              ),
              const Chip(
                label: Text(
                  'Gray',
                ),
                side: BorderSide.none,
                backgroundColor: Colors.black26,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Font Color',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Chip(label: Text('White'))),
              Expanded(child: Chip(label: Text('Black'))),
              Expanded(child: Chip(label: Text('Red'))),
              Expanded(child: Chip(label: Text('Red'))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font Size',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Text('14pt')
            ],
          )
        ],
      ),
    );
  }
}

var chapterDataProvider =
    FutureProvider.family<ChapterData, String>((ref, currentNovel) async {
  var currentChapter = await NovelService.getNovelChapter(currentNovel);
  //set text
  ref.read(textToSpeechProvider.notifier).updateText(currentChapter.text);
  return currentChapter;
});

var textToSpeechProvider = StateNotifierProvider<TextToSpeechNotifier, String>(
    (ref) => TextToSpeechNotifier(''));

class TextToSpeechNotifier extends StateNotifier<String> {
  TextToSpeechNotifier(super.state);

  updateText(String text) {
    state = state + text;
  }
}
