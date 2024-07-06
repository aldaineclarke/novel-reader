import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:novel_reader/providers/chapter_list_provider.dart';
import 'package:novel_reader/services/novel_service.dart';
import 'package:go_router/go_router.dart';

class NovelDetailsPage extends ConsumerWidget {
  const NovelDetailsPage({required this.novelId, super.key});
  final String novelId;
  static const routeName = 'Novel List';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novelDetailsFuture = ref.watch(novelDetailsProvider(novelId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            return GoRouter.of(context).go('/');
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
            final match = regExp.firstMatch(novelData.lastChapter);
            return Padding(
              padding: const EdgeInsets.all(20.0),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.lime,
                            size: 18,
                          ),
                          SizedBox(width: 10),
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
                          GoRouter.of(context).go(
                              '/novels/${novelData.chapters[0]['id']}/chapters');
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
                          GoRouter.of(context).go(
                              '/novels/view/${novelData.chapters[0]['id']}');
                        },
                        child: const Text('Start Reading'),
                      ),
                      TextButton(
                        onPressed: () {},
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.lime),
                        child: const Text('Add to Shelf'),
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
