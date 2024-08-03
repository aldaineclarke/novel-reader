import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:novel_reader/env.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';
import 'package:novel_reader/models/chapter_data.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:novel_reader/providers/chapter_list_provider.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';
import 'package:novel_reader/providers/preference_provider.dart';
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
        // Copy with not working  correctly
        final updatedNovel = novel?.copyWith(currentChapterId: currentNovel);
        novelBox.put('currentNovel', updatedNovel!);
        ref
            .read(shelfProvider.notifier)
            .updateNovelCurrentChapter(updatedNovel);
        ref.read(currentNovelProvider.notifier).setNovel(updatedNovel);
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

  Widget _buildPanel(BuildContext context, String title) {
    return Material(
      elevation: 5,
      child: Container(
        height: 100, // Adjust the height of the panel
        color: Colors.brown,
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
                print('hey');
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
                // Navigator.of(context).push();
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
    final textToSpeech = ref.watch(textToSpeechProvider);
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
                  height: MediaQuery.of(context).size.height * .4,
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

class NovelViewOptionPanel extends ConsumerStatefulWidget {
  const NovelViewOptionPanel({super.key});

  @override
  _NovelViewOptionPanelState createState() => _NovelViewOptionPanelState();
}

class _NovelViewOptionPanelState extends ConsumerState<NovelViewOptionPanel> {
  double _currentSliderValue = 0.7;
  static const brightnessChannel = MethodChannel('brightnessPlatform');

  Future<void> _setBrightness(double brightness) async {
    try {
      print('BrightNess: $brightness');
      await brightnessChannel
          .invokeMethod('setBrightness', {'brightness': brightness});
    } on PlatformException catch (e) {
      print("Failed to set brightness: '${e}'.");
    }
  }

  Future<void> _getBrightness() async {
    try {
      final brightessVal =
          await brightnessChannel.invokeMethod('getBrightness');
    } on PlatformException catch (e) {
      print("Failed to set brightness: '${e}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferenceProvider);
    return Material(
      elevation: 3,
      shadowColor: Colors.black,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      clipBehavior: Clip.hardEdge,
      child: Container(
        color: Color.fromARGB(255, 255, 245, 245),
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
                      max: 1,
                      value: _currentSliderValue,
                      onChanged: (value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                      onChangeEnd: _setBrightness,
                    ),
                  ),
                ),
                const Icon(Icons.brightness_high, size: 16)
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Page Themes',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          minimumSize: Size(40, 20), // Adjust the minimum size

                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {
                        preferences
                          ..setBackgroundColor(Colors.white)
                          ..setFontColor(Colors.black87);
                      },
                      child: const Text(
                        'Blanc',
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFf8fd98),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        minimumSize:
                            const Size(40, 20), // Adjust the minimum size

                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onPressed: () {
                      preferences
                        ..setBackgroundColor(const Color(0xFFf8fd98))
                        ..setFontColor(Colors.black87);
                    },
                    child: const Text(
                      'Sunlit',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          minimumSize:
                              const Size(40, 20), // Adjust the minimum size

                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {
                        preferences
                          ..setBackgroundColor(Colors.black54)
                          ..setFontColor(Colors.white70);
                      },
                      child: const Text(
                        'Dark Light',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEDD1B0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          minimumSize:
                              const Size(40, 20), // Adjust the minimum size

                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {
                        preferences
                          ..setBackgroundColor(const Color(0xFFEDD1B0))
                          ..setFontColor(Colors.brown[900]!);
                      },
                      child: const Text(
                        'Vintage',
                        style: TextStyle(color: Colors.brown),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Font Size',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          preferences.setFontSize(preferences.fontSize - 1);
                        },
                        child: const Text(
                          'A-',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(width: 10),
                    Text('${preferences.fontSize.toInt()}pt'),
                    const SizedBox(width: 10),
                    InkWell(
                        onTap: () {
                          preferences.setFontSize(preferences.fontSize + 1);
                        },
                        child: const Text(
                          'A+',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                  ],
                )
              ],
            )
          ],
        ),
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
