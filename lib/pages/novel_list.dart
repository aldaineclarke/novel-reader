import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/models/novel_item.dart';
import 'package:novel_reader/pages/novel_details.dart';
import 'package:novel_reader/providers/novel_notifier_provider.dart';

class NovelListScreen extends ConsumerStatefulWidget {
  const NovelListScreen(
      {required this.listId, required this.provider, super.key});
  final String listId;
  final StateNotifierProvider<NovelsNotifier, List<NovelItem>> provider;
  static const routeName = 'novellist';

  @override
  ConsumerState<NovelListScreen> createState() => _NovelListScreenState();
}

class _NovelListScreenState extends ConsumerState<NovelListScreen> {
  bool showBackToTopBtn = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final novels = ref.watch(widget.provider);
    final notifier = ref.read(widget.provider.notifier);
    return RefreshIndicator(
      onRefresh: () {
        ref.read(widget.provider.notifier).refreshList();
        return Future.delayed(const Duration(seconds: 3));
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(kebabToCapitalizedWords(widget.listId)),
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              notifier.fetchNovels();
            }

            if (scrollInfo.metrics.pixels >
                MediaQuery.of(context).size.height) {
              setState(() {
                showBackToTopBtn = true;
              });
            } else if (showBackToTopBtn == true) {
              setState(() {
                showBackToTopBtn = false;
              });
            }
            return false;
          },
          child: novels.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Scrollbar(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: novels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final novelItem = novels[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  NovelDetailsPage(novelId: novelItem.id),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 200,
                          width: 150,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image(
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.indigo),
                                        image: const DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              'assets/images/loading_img.jpg'),
                                        ),
                                      ),
                                    );
                                  },
                                  image: NetworkImage(novelItem.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      novelItem.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      textAlign: TextAlign.start,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          color: Colors.lime,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                            novelItem.lastChapter,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            softWrap: false,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      child: Wrap(
                                        runSpacing: 2,
                                        spacing: 2,
                                        children: novelItem.genres.map((e) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                left: Radius.circular(10),
                                                right: Radius.circular(10),
                                              ),
                                              color: Color.fromARGB(
                                                  255, 249, 255, 255),
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromARGB(
                                                    255, 12, 58, 95),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        floatingActionButton: showBackToTopBtn
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                child: const Icon(Icons.arrow_upward_rounded),
              )
            : null,
      ),
    );
  }
}

String kebabToCapitalizedWords(String input) {
  return input
      .split('-') // Split the string by hyphens
      .map((word) =>
          word[0].toUpperCase() +
          word.substring(1).toLowerCase()) // Capitalize each word
      .join(' '); // Join the words with a space
}
