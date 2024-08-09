import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';
import 'package:novel_reader/models/novel_item.dart';
import 'package:novel_reader/pages/novel_details.dart';
import 'package:novel_reader/pages/novel_list.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';
import 'package:novel_reader/providers/novel_notifier_provider.dart';
import 'package:novel_reader/services/novel_service.dart';

class DiscoverTab extends ConsumerStatefulWidget {
  const DiscoverTab({super.key});

  @override
  ConsumerState<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<DiscoverTab> {
  final TextEditingController searchCtrl = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      // Perform your action here (e.g., API call)
      setState(() {
        searchCtrl.text = query;
      });
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentNovel = ref.watch(currentNovelProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      children: [
        TextField(
          controller: searchCtrl,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            labelText: 'Search Novel',
            labelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.blue,
            ),
            suffixIcon: (searchCtrl.text != '')
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        searchCtrl.text = '';
                      });
                    },
                    child: const Icon(Icons.close_rounded),
                  )
                : null,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              borderSide: BorderSide(color: Color.fromARGB(255, 194, 224, 236)),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              borderSide: BorderSide(color: Colors.amber, width: 2),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        if (searchCtrl.text == '')
          ...showScreenContent(currentNovel, context)
        else
          FutureBuilder(
              future: NovelService.searchNovel(searchCtrl.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final novelItem = snapshot.data![index];
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
                          // color: Colors.limeAccent,
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
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Text('There is no content');
                }
              }),
      ],
    );
  }

  List<Widget> showScreenContent(
      CurrentNovel? currentNovel, BuildContext context) {
    return [
      if (currentNovel != null)
        Container(
          height: 250,
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.black26),
          ),
          child: Row(
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
                          image: AssetImage('assets/images/loading_img.jpg'),
                        ),
                      ),
                    );
                  },
                  image: NetworkImage(currentNovel.novelImage),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentNovel.novelTitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                    ),
                    Text(
                      currentNovel.author,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        currentNovel.description,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        // Since we will only have access to the last chapter
                        // We need to navigate to the chapter to let the user read
                        // as well as fetch the subsequent chapters for that page
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                NovelDetailsPage(novelId: currentNovel.novelId),
                          ),
                        );
                      },
                      child: const Text('Continue '),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      else
        const SizedBox.shrink(),
      NovelSectionWidget(
        sectionHeader: 'Latest Release',
        ctaText: 'See All',
        routeName: 'latest-release',
        provider: latestReleasesProvider,
      ),
      const SizedBox(height: 20),
      NovelSectionWidget(
        sectionHeader: 'New Novels',
        ctaText: 'See All',
        routeName: 'new-novels',
        provider: newNovelsProvider,
      ),
      const SizedBox(height: 20),
      NovelSectionWidget(
        sectionHeader: 'Completed Novels',
        ctaText: 'See All',
        routeName: 'complete-novels',
        provider: completedNovelsProvider,
      ),
      const SizedBox(height: 20),
      NovelSectionWidget(
        sectionHeader: 'Most Popular',
        ctaText: 'See All',
        routeName: 'most-popular',
        provider: mostPopularNovelsProvider,
      ),
    ];
  }
}

class NovelSectionWidget extends ConsumerWidget {
  const NovelSectionWidget({
    required this.sectionHeader,
    required this.ctaText,
    required this.routeName,
    required this.provider,
    super.key,
  });
  final String sectionHeader;
  final String ctaText;
  final String routeName;
  final StateNotifierProvider<NovelsNotifier, List<NovelItem>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionHeader,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                // GoRouter.of(context).go(
                //   Uri(path: '/novel-list/$routeName').toString(),
                // );
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => NovelListScreen(
                      listId: routeName,
                      provider: getNovelProvider(routeName),
                    ),
                  ),
                );
              },
              child: const Text('See All'),
            )
          ],
        ),
        SizedBox(
          height: 250,
          child: FutureBuilder(
            future: NovelService.getNovelList(routeName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Has the error ${snapshot.error}');
              } else {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 20, height: 20),
                  itemBuilder: (BuildContext context, int index) {
                    final novelItem = snapshot.data![index];
                    return InkWell(
                      onTap: () {
                        // return GoRouter.of(context)
                        //     .go('/novels/${novelItem.id}');

                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                NovelDetailsPage(novelId: novelItem.id),
                          ),
                        );
                      },
                      child: NovelItemWidget(novelItem: novelItem),
                    );
                  },
                );
              }
            },
          ),
        )
      ],
    );
  }
}

class NovelItemWidget extends StatelessWidget {
  const NovelItemWidget({
    super.key,
    required this.novelItem,
  });

  final NovelItem novelItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      // color: Colors.limeAccent,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image(
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
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
                                image: AssetImage(
                                  'assets/images/loading_img.jpg',
                                ),
                              ),
                            ),
                          );
                        },
                        image: NetworkImage(novelItem.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                image: NetworkImage(novelItem.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            novelItem.title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            softWrap: false,
            overflow: TextOverflow.fade,
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
                  style: Theme.of(context).textTheme.bodySmall,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
