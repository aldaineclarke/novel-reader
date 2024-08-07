import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';
import 'package:novel_reader/models/chapter_data.dart';
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

            // Find all matches in the input string
            final firstChapter =
                ChapterListItem.fromJson(novelData.chapters[0]);
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
                                  NovelChapterList(novelId: firstChapter.id),
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
                          ref
                              .read(currentNovelProvider.notifier)
                              .setNovel(novel);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  NovelView(novelChapter: firstChapter.id),
                            ),
                          );
                        },
                        child: const Text('Start Reading'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(shelfProvider.notifier)
                              .addNovelToShelf(novel);
                          setState(() {});
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
