import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/hive_adapters/chapter_list_item.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';
import 'package:novel_reader/pages/novel_chapter_list.dart';
import 'package:novel_reader/pages/novel_view.dart';
import 'package:novel_reader/providers/chapter_list_provider.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';
import 'package:novel_reader/providers/shelf_provider.dart';

class NovelDetailsPage extends ConsumerStatefulWidget {
  const NovelDetailsPage({required this.novelId, super.key});
  final String novelId;
  static const routeName = 'Novel List';

  @override
  ConsumerState<NovelDetailsPage> createState() => _NovelDetailsPageState();
}

class _NovelDetailsPageState extends ConsumerState<NovelDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final novelDetailsFuture = ref.watch(novelDetailsProvider(widget.novelId));
    // final currentNovel = ref.watch(currentNovelProvider);
    final shelf = ref.watch(shelfProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Book Details'),
      ),
      body: novelDetailsFuture.when(
          error: (error, stackTrace) => const Text('No Content'),
          loading: () => const Center(child: CircularProgressIndicator()),
          data: (novelData) {
            // Define a regular expression to match digits
            final regExp = RegExp(r'\d+');

            // gets the chapterList from the novelInSelf if it exists instead of the default
            var chapterList =
                novelData.chapters.map(ChapterListItem.fromJson).toList();
            var firstChapter = ChapterListItem.fromJson(novelData.chapters[0]);
            CurrentNovel? novelInShelf;
            try {
              novelInShelf = shelf
                  .where(
                    (element) => element.novelId == novelData.id,
                  )
                  .first;
              chapterList = novelInShelf.chapterList;
              if (kDebugMode) {
                print(
                    'chapterLogs: ShelfNovel currentChap -  ${novelInShelf?.currentChapterId}');
              }
              firstChapter = chapterList
                  .where((c) => c.id == novelInShelf?.currentChapterId)
                  .first;
              if (kDebugMode) {
                print('chapterLogs: firstChapter -  ${firstChapter.title}');
              }
            } on StateError catch (e) {
              novelInShelf = null;
            }

            // Find all matches in the input string

            final match = regExp.firstMatch(novelData.lastChapter);

            final novel = CurrentNovel(
              novelTitle: novelData.title,
              novelId: novelData.id,
              novelImage: novelData.image,
              genres: novelData.genres,
              author: novelData.author,
              description: novelData.description,
              currentChapterId: firstChapter.id,
              chapterCount: novelData.pages ?? 1,
              chapterList: chapterList,
              currentPage: 1,
            );

            // Waits until the widget tree builds then set the novelProvider
            Future(
              () {
                print('This was ran');
                ref.read(currentNovelProvider.notifier).setNovel(novel);
              },
            );

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image(
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.indigo),
                              image: const DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage('assets/images/loading_img.jpg'),
                              ),
                            ),
                          );
                        },
                        image: NetworkImage(novelData.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              novelData.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.fade,
                            ),
                            Text(
                              novelData.author,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.lime,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text('${novelData.rating} stars')
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  NovelChapterList(novelId: novel.novelId),
                            ),
                          );
                        },
                        child: Chip(
                          label: Text('${match!.group(0)!}'),
                          avatar: const Icon(Icons.book),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Chip(
                        label: Text(novelData.status),
                        avatar: const Icon(Icons.adjust_sharp),
                      ),
                      const SizedBox(width: 10),
                      Chip(
                        label: Text('${novelData.views}'),
                        avatar: const Icon(Icons.remove_red_eye),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        Text(
                          novelData.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // print(curren);

                          var chapterId = firstChapter.id;
                          if (novelInShelf != null) {
                            chapterId = novelInShelf.currentChapterId;
                            // novelInShelf.chapterList
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  NovelView(novelChapter: chapterId),
                            ),
                          );
                        },
                        child: (novelInShelf == null)
                            ? const Text('Start Reading')
                            : Text(
                                'Continue Chapter ${regExp.firstMatch(novelInShelf.currentChapterId)?.group(0)}',
                              ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(shelfProvider.notifier)
                              .addNovelToShelf(novel);
                        },
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.lime),
                        child: (ref
                                .read(shelfProvider.notifier)
                                .novelInShelf(novel))
                            ? const Text('On Shelf')
                            : const Text('Add to Shelf'),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}
