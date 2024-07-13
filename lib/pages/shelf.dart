import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:novel_reader/env.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';
import 'package:novel_reader/pages/novel_details.dart';
import 'package:novel_reader/providers/shelf_provider.dart';
import 'package:novel_reader/services/novel_service.dart';

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
        title: const Text('My Shelf'),
      ),
      body: (shelf.isEmpty)
          ? const Center(
              child: Text('Shelf is Empty'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: shelf.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final novelItem = shelf[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            NovelDetailsPage(novelId: novelItem.novelId),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                novelItem.novelTitle,
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
                                      '${novelItem.chapterCount}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                                        color:
                                            Color.fromARGB(255, 249, 255, 255),
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
            ),
    );
  }
}
