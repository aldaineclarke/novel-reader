import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterboilerplate/home_tabs/discover.dart';
import 'package:flutterboilerplate/services/novel_service.dart';
import 'package:go_router/go_router.dart';

class NovelListScreen extends StatelessWidget {
  const NovelListScreen({required this.listId, super.key});
  final String listId;
  static const routeName = 'novellist';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            return GoRouter.of(context).go('/');
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Novel List'),
      ),
      body: FutureBuilder(
          future: NovelService.getNovelList(listId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final novelItem = snapshot.data![index];
                  return InkWell(
                    onTap: () {
                      return GoRouter.of(context).go('/novels/${novelItem.id}');
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
                                    border: Border.all(color: Colors.indigo),
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
                              children: [
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: novelItem.genres.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                      width: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Chip(
                                        label: Text(novelItem.genres[index]),
                                      );
                                    },
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
    );
  }
}
