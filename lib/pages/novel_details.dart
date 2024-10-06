import 'package:babel_novel/models/novel_item.dart';
import 'package:babel_novel/providers/chapter_list_provider.dart';
import 'package:babel_novel/providers/current_chapter_provider.dart';
import 'package:babel_novel/providers/novel_detail_provider.dart';
import 'package:babel_novel/services/error_dialog_service.dart';
import 'package:babel_novel/widgets/error_display_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_novel/hive_adapters/chapter_list_item.dart';
import 'package:babel_novel/hive_adapters/current_novel.dart';
import 'package:babel_novel/pages/novel_chapter_list.dart';
import 'package:babel_novel/pages/novel_view.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:babel_novel/providers/shelf_provider.dart';
import 'package:babel_novel/utils/theme_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NovelDetailsPage extends ConsumerStatefulWidget {
  const NovelDetailsPage({required this.novel, super.key});
  final NovelItem novel;
  static const routeName = 'Novel List';

  @override
  ConsumerState<NovelDetailsPage> createState() => _NovelDetailsPageState();
}

class _NovelDetailsPageState extends ConsumerState<NovelDetailsPage> {
  bool isLoading = false;

  void _retry() {
    setState(() {
      isLoading = true; // Show loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    final novelDetailsFuture = ref.watch(novelDetailsProvider(widget.novel.id));
    // final currentNovel = ref.watch(currentNovelProvider);
    const novelTag = 'DetailTag';
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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Hero(
                    tag: 'DetailTag',
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
                      image: NetworkImage(widget.novel.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              novelDetailsFuture.when(
                loading: () => Expanded(
                  child: ListView(
                    children: [
                      Skeletonizer(
                        enabled: true,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Skeleton.keep(
                                        child: Text(
                                          widget.novel.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                      Text(
                                        'This is static data',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  ),
                                ),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.lime,
                                      size: 18,
                                    ),
                                    SizedBox(width: 10),
                                    Text('stars')
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
                                            NovelChapterList(
                                                novelId: widget.novel.id),
                                      ),
                                    );
                                  },
                                  child: const Chip(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: ThemeColors.teal),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                      ),
                                    ),
                                    label: Text('${0} Chap'),
                                    avatar: Icon(Icons.book),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Chip(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: ThemeColors.teal),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  label: Text('status'),
                                  avatar: Icon(Icons.adjust_sharp),
                                ),
                                const SizedBox(width: 10),
                                const Chip(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: ThemeColors.teal),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  label: Text('${'views'}'),
                                  avatar: Icon(Icons.remove_red_eye),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('''
                                (Riverpod) or a ChangeNotifier (Provider), for instance, allows you to manage the loading state in a more centralized way while reducing rebuilds.
                        
                              '''),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Continue ',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('New Text'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                data: (novelData) {
                  isLoading = false;
                  // Define a regular expression to match digits
                  final regExp = RegExp(r'\d+');

                  // gets the chapterList from the novelInSelf if it exists instead of the default
                  var chapterList =
                      novelData.chapters.map(ChapterListItem.fromJson).toList();
                  var firstChapter =
                      ChapterListItem.fromJson(novelData.chapters[0]);
                  CurrentNovel? novelInShelf;
                  try {
                    final novelInShelfList = shelf
                        .where(
                          (element) => element.novelId == novelData.id,
                        )
                        .toList();

                    if (novelInShelfList.isNotEmpty) {
                      novelInShelf = novelInShelfList.first;
                      chapterList = novelInShelf.chapterList;
                    }
                    if (kDebugMode) {
                      print(
                          'chapterLogs: ShelfNovel currentChap -  ${novelInShelf?.currentChapterId}');
                      print(novelData.chapters);
                    }
                    final chapterId = chapterList
                        .where((c) => c.id == novelInShelf?.currentChapterId)
                        .toList();
                    if (chapterId.isNotEmpty) {
                      firstChapter = chapterId.first;
                    }
                    if (kDebugMode) {
                      print(
                          'chapterLogs: firstChapter -  ${firstChapter.title}');
                    }
                  } catch (e) {
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
                      //I use 40 here because by default that is how much chapters available in one page.
                      ref.read(totalNovelPages.notifier).state =
                          chapterList.length;
                      ref
                          .read(chapterListProvider.notifier)
                          .setChapterListItem(chapterList);

                      ref.read(currentNovelProvider.notifier).setNovel(novel);
                    },
                  );

                  return Expanded(
                    child: Column(
                      children: [
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
                                        NovelChapterList(
                                            novelId: novel.novelId),
                                  ),
                                );
                              },
                              child: Chip(
                                shape: const RoundedRectangleBorder(
                                  side: BorderSide(color: ThemeColors.teal),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                label: Text('${chapterList.length} Chap'),
                                avatar: const Icon(Icons.book),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(color: ThemeColors.teal),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              label: Text(novelData.status),
                              avatar: const Icon(Icons.adjust_sharp),
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(color: ThemeColors.teal),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
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
                        const SizedBox(
                          height: 10,
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
                              style: TextButton.styleFrom(
                                  backgroundColor: ThemeColors.teal),
                              child: (ref
                                      .read(shelfProvider.notifier)
                                      .novelInShelf(novel))
                                  ? const Text(
                                      'On Shelf',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : const Text(
                                      'Add to Shelf',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ErrorDisplayWidget(
                          message: (error as DioException).error.toString(),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Refetch the data by triggering the provider
                            ref
                                .read(novelDetailsProvider(widget.novel.id)
                                    .notifier)
                                .fetchNovelDetails();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     TextButton(
              //       onPressed: () {
              //         // print(curren);

              //         var chapterId = firstChapter.id;
              //         if (novelInShelf != null) {
              //           chapterId = novelInShelf.currentChapterId;
              //           // novelInShelf.chapterList
              //         }
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute<void>(
              //             builder: (context) =>
              //                 NovelView(novelChapter: chapterId),
              //           ),
              //         );
              //       },
              //       child: (novelInShelf == null)
              //           ? const Text('Start Reading')
              //           : Text(
              //               'Continue Chapter ${regExp.firstMatch(novelInShelf.currentChapterId)?.group(0)}',
              //             ),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         ref
              //             .read(shelfProvider.notifier)
              //             .addNovelToShelf(novel);
              //       },
              //       style: TextButton.styleFrom(
              //           backgroundColor: ThemeColors.teal),
              //       child: (ref
              //               .read(shelfProvider.notifier)
              //               .novelInShelf(novel))
              //           ? const Text(
              //               'On Shelf',
              //               style: TextStyle(color: Colors.white),
              //             )
              //           : const Text(
              //               'Add to Shelf',
              //               style: TextStyle(color: Colors.white),
              //             ),
              //     ),
              //   ],
              // )
            ],
          ),
        )
        // body: novelDetailsFuture.when(
        //     error: (error, stackTrace) {
        //       return Center(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             ErrorDisplayWidget(
        //               message: (error as DioException).error.toString(),
        //             ),
        //             ElevatedButton(
        //               onPressed: () {
        //                 // Refetch the data by triggering the provider
        //                 ref
        //                     .read(novelDetailsProvider(widget.novelId).notifier)
        //                     .fetchNovelDetails();
        //               },
        //               child: const Text('Try Again'),
        //             ),
        //           ],
        //         ),
        //       );
        //     },
        //     loading: () => const Center(child: CircularProgressIndicator()),
        //     data: (novelData) {
        //       isLoading = false;
        //       // Define a regular expression to match digits
        //       final regExp = RegExp(r'\d+');

        //       // gets the chapterList from the novelInSelf if it exists instead of the default
        //       var chapterList =
        //           novelData.chapters.map(ChapterListItem.fromJson).toList();
        //       var firstChapter = ChapterListItem.fromJson(novelData.chapters[0]);
        //       CurrentNovel? novelInShelf;
        //       try {
        //         final novelInShelfList = shelf
        //             .where(
        //               (element) => element.novelId == novelData.id,
        //             )
        //             .toList();

        //         if (novelInShelfList.isNotEmpty) {
        //           novelInShelf = novelInShelfList.first;
        //           chapterList = novelInShelf.chapterList;
        //         }
        //         if (kDebugMode) {
        //           print(
        //               'chapterLogs: ShelfNovel currentChap -  ${novelInShelf?.currentChapterId}');
        //           print(novelData.chapters);
        //         }
        //         final chapterId = chapterList
        //             .where((c) => c.id == novelInShelf?.currentChapterId)
        //             .toList();
        //         if (chapterId.isNotEmpty) {
        //           firstChapter = chapterId.first;
        //         }
        //         if (kDebugMode) {
        //           print('chapterLogs: firstChapter -  ${firstChapter.title}');
        //         }
        //       } catch (e) {
        //         novelInShelf = null;
        //       }

        //       // Find all matches in the input string

        //       final match = regExp.firstMatch(novelData.lastChapter);

        //       final novel = CurrentNovel(
        //         novelTitle: novelData.title,
        //         novelId: novelData.id,
        //         novelImage: novelData.image,
        //         genres: novelData.genres,
        //         author: novelData.author,
        //         description: novelData.description,
        //         currentChapterId: firstChapter.id,
        //         chapterCount: novelData.pages ?? 1,
        //         chapterList: chapterList,
        //         currentPage: 1,
        //       );

        //       // Waits until the widget tree builds then set the novelProvider
        //       Future(
        //         () {
        //           //I use 40 here because by default that is how much chapters available in one page.
        //           ref.read(totalNovelPages.notifier).state = chapterList.length;
        //           ref
        //               .read(chapterListProvider.notifier)
        //               .setChapterListItem(chapterList);

        //           ref.read(currentNovelProvider.notifier).setNovel(novel);
        //         },
        //       );

        //       return Padding(
        //         padding: const EdgeInsets.all(20),
        //         child: Column(
        //           children: [
        //             SizedBox(
        //               height: MediaQuery.of(context).size.height * .3,
        //               child: ClipRRect(
        //                 borderRadius: BorderRadius.circular(15),
        //                 child: Image(
        //                   loadingBuilder: (BuildContext context, Widget child,
        //                       ImageChunkEvent? loadingProgress) {
        //                     if (loadingProgress == null) {
        //                       return child;
        //                     }
        //                     return Container(
        //                       decoration: BoxDecoration(
        //                         border: Border.all(color: Colors.indigo),
        //                         image: const DecorationImage(
        //                           fit: BoxFit.cover,
        //                           image:
        //                               AssetImage('assets/images/loading_img.jpg'),
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                   image: NetworkImage(novelData.image),
        //                   fit: BoxFit.cover,
        //                 ),
        //               ),
        //             ),
        //             const SizedBox(
        //               height: 20,
        //             ),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 Expanded(
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     mainAxisSize: MainAxisSize.min,
        //                     children: [
        //                       Text(
        //                         novelData.title,
        //                         style: Theme.of(context)
        //                             .textTheme
        //                             .bodyLarge
        //                             ?.copyWith(fontWeight: FontWeight.w700),
        //                         overflow: TextOverflow.fade,
        //                       ),
        //                       Text(
        //                         novelData.author,
        //                         style: Theme.of(context)
        //                             .textTheme
        //                             .bodySmall
        //                             ?.copyWith(fontWeight: FontWeight.w500),
        //                         overflow: TextOverflow.fade,
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 Row(
        //                   children: [
        //                     const Icon(
        //                       Icons.star,
        //                       color: Colors.lime,
        //                       size: 18,
        //                     ),
        //                     const SizedBox(width: 10),
        //                     Text('${novelData.rating} stars')
        //                   ],
        //                 )
        //               ],
        //             ),
        //             const SizedBox(height: 20),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 InkWell(
        //                   onTap: () {
        //                     Navigator.push(
        //                       context,
        //                       MaterialPageRoute<void>(
        //                         builder: (BuildContext context) =>
        //                             NovelChapterList(novelId: novel.novelId),
        //                       ),
        //                     );
        //                   },
        //                   child: Chip(
        //                     shape: const RoundedRectangleBorder(
        //                       side: BorderSide(color: ThemeColors.teal),
        //                       borderRadius: BorderRadius.all(
        //                         Radius.circular(30),
        //                       ),
        //                     ),
        //                     label: Text('${chapterList.length} Chap'),
        //                     avatar: const Icon(Icons.book),
        //                   ),
        //                 ),
        //                 const SizedBox(width: 10),
        //                 Chip(
        //                   shape: const RoundedRectangleBorder(
        //                     side: BorderSide(color: ThemeColors.teal),
        //                     borderRadius: BorderRadius.all(
        //                       Radius.circular(30),
        //                     ),
        //                   ),
        //                   label: Text(novelData.status),
        //                   avatar: const Icon(Icons.adjust_sharp),
        //                 ),
        //                 const SizedBox(width: 10),
        //                 Chip(
        //                   shape: const RoundedRectangleBorder(
        //                     side: BorderSide(color: ThemeColors.teal),
        //                     borderRadius: BorderRadius.all(
        //                       Radius.circular(30),
        //                     ),
        //                   ),
        //                   label: Text('${novelData.views}'),
        //                   avatar: const Icon(Icons.remove_red_eye),
        //                 ),
        //               ],
        //             ),
        //             const SizedBox(height: 20),
        //             Expanded(
        //               child: ListView(
        //                 children: [
        //                   Text(
        //                     novelData.description,
        //                     style: Theme.of(context).textTheme.bodyMedium,
        //                     overflow: TextOverflow.fade,
        //                     textAlign: TextAlign.start,
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             const SizedBox(
        //               height: 10,
        //             ),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 TextButton(
        //                   onPressed: () {
        //                     // print(curren);

        //                     var chapterId = firstChapter.id;
        //                     if (novelInShelf != null) {
        //                       chapterId = novelInShelf.currentChapterId;
        //                       // novelInShelf.chapterList
        //                     }
        //                     Navigator.push(
        //                       context,
        //                       MaterialPageRoute<void>(
        //                         builder: (context) =>
        //                             NovelView(novelChapter: chapterId),
        //                       ),
        //                     );
        //                   },
        //                   child: (novelInShelf == null)
        //                       ? const Text('Start Reading')
        //                       : Text(
        //                           'Continue Chapter ${regExp.firstMatch(novelInShelf.currentChapterId)?.group(0)}',
        //                         ),
        //                 ),
        //                 TextButton(
        //                   onPressed: () {
        //                     ref
        //                         .read(shelfProvider.notifier)
        //                         .addNovelToShelf(novel);
        //                   },
        //                   style: TextButton.styleFrom(
        //                       backgroundColor: ThemeColors.teal),
        //                   child: (ref
        //                           .read(shelfProvider.notifier)
        //                           .novelInShelf(novel))
        //                       ? const Text(
        //                           'On Shelf',
        //                           style: TextStyle(color: Colors.white),
        //                         )
        //                       : const Text(
        //                           'Add to Shelf',
        //                           style: TextStyle(color: Colors.white),
        //                         ),
        //                 ),
        //               ],
        //             )
        //           ],
        //         ),
        //       );
        //     }),

        );
  }
}
