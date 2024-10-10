import 'package:babel_novel/models/novel_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babel_novel/pages/novel_details.dart';
import 'package:babel_novel/providers/shelf_provider.dart';
import 'package:babel_novel/utils/theme_colors.dart';

class ShelfScreen extends ConsumerStatefulWidget {
  const ShelfScreen({super.key});

  @override
  ConsumerState<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends ConsumerState<ShelfScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Shelf',
        ),
      ),
      body: (shelf.isEmpty)
          ? const Center(
              child: Text('Shelf is Empty'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              itemCount: shelf.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final novelItem = shelf[index];
                return InkWell(
                  onTap: () {
                    if (kDebugMode) {
                      print('Item: ${novelItem.toString()}');
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => NovelDetailsPage(
                          novel: NovelItem(
                            genres: novelItem.genres,
                            id: novelItem.novelId,
                            image: novelItem.novelImage,
                            lastChapter: novelItem.currentChapterId,
                            url: novelItem.novelId,
                            title: novelItem.novelTitle,
                          ), // not sure if this will convert it to a map
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 200,
                    // color: Colors.limeAccent,
                    width: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
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
                                    image: AssetImage(
                                        'assets/images/loading_img.jpg'),
                                  ),
                                ),
                              );
                            },
                            image: NetworkImage(novelItem.novelImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      novelItem.novelTitle,
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
                                            'Completed',
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
                                    Expanded(
                                      child: ListView(
                                        children: [
                                          Wrap(
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
                                                padding:
                                                    const EdgeInsets.all(5),
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  height: 5,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color.fromARGB(
                                          156, 158, 158, 158)),
                                  width: double.maxFinite,
                                  // width: double.infinity,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: novelItem.chapterCount /
                                          novelItem.chapterList
                                              .length, // 20% of the parent's width

                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary, // Child's color for visualization
                                      ),
                                    ),
                                  )),
                              TextButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Remove Novel'),
                                        content: RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style, // Inherit default text style
                                            children: <TextSpan>[
                                              const TextSpan(
                                                text:
                                                    'Are you sure you want to remove the novel from your shelf? \n\n',
                                                // Customize the style
                                              ),
                                              TextSpan(
                                                text: novelItem.novelTitle,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        18), // Customize the style
                                              ),
                                            ],
                                          ),
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Colors.black26),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final novelIndex =
                                                  shelf.indexOf(novelItem);
                                              ref
                                                  .read(shelfProvider.notifier)
                                                  .removeFromShelf(novelIndex);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Remove Novel',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Remove Novel',
                                      style: TextStyle(
                                        color: ThemeColors.brickRed,
                                      ),
                                    ),
                                    // Icon(Icons.delete_rounded),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
