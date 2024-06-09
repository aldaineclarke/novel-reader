import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterboilerplate/models/novel_item.dart';
import 'package:flutterboilerplate/services/novel_service.dart';
import 'package:go_router/go_router.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
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
              const Image(
                image: AssetImage('assets/images/super_gene.jpg'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Super Gene and the super',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                    ),
                    Text(
                      'Twelve Suns Lonely',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 10),
                    const Expanded(
                      child: Text(
                        'Synopsis of Book that will be shown to the user upon load of this book. It should be long enough to make a elipsis or rather it should fade over the content that is below',
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(onPressed: () {}, child: const Text('Continue '))
                  ],
                ),
              )
            ],
          ),
        ),
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
            TextButton(onPressed: () {}, child: const Text('See All'))
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
                          return GoRouter.of(context)
                              .go('/novel/${novelItem.id}');
                        },
                        child: NovelItemWidget(novelItem: novelItem),
                      );
                    });
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
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/loading_img.jpg'),
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
