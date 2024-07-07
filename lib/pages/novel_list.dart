import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:novel_reader/home_tabs/discover.dart';
import 'package:novel_reader/pages/novel_details.dart';
import 'package:novel_reader/pages/novel_view.dart';
import 'package:novel_reader/services/novel_service.dart';
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
            Navigator.of(context).pop();
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  novelItem.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
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
                                          borderRadius: BorderRadius.horizontal(
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
                                            color:
                                                Color.fromARGB(255, 12, 58, 95),
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
    );
  }
}
