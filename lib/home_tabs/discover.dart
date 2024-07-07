import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/models/novel_item.dart';
import 'package:novel_reader/pages/novel_details.dart';
import 'package:novel_reader/pages/novel_list.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';
import 'package:novel_reader/services/novel_service.dart';

class DiscoverTab extends ConsumerWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentNovel = ref.watch(currentNovelProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600, height: 1.2),
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
                        onPressed: () {},
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
        const NovelSectionWidget(
          sectionHeader: 'Latest Release',
          ctaText: 'See All',
          routeName: 'latest-release',
        ),
        const SizedBox(height: 20),
        const NovelSectionWidget(
          sectionHeader: 'New Novels',
          ctaText: 'See All',
          routeName: 'new-novels',
        ),
        const SizedBox(height: 20),
        const NovelSectionWidget(
          sectionHeader: 'Completed Novels',
          ctaText: 'See All',
          routeName: 'complete-novels',
        ),
        const SizedBox(height: 20),
        const NovelSectionWidget(
          sectionHeader: 'Most Popular',
          ctaText: 'See All',
          routeName: 'most-popular',
        ),
      ],
    );
  }
}

class NovelSectionWidget extends StatelessWidget {
  const NovelSectionWidget({
    required this.sectionHeader,
    required this.ctaText,
    required this.routeName,
    super.key,
  });
  final String sectionHeader;
  final String ctaText;
  final String routeName;

  @override
  Widget build(BuildContext context) {
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
                    builder: (context) => NovelListScreen(listId: routeName),
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
