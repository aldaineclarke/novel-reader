import 'package:babel_novel/widgets/error_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_novel/pages/novel_list.dart';
import 'package:babel_novel/providers/novel_notifier_provider.dart';
import 'package:babel_novel/services/novel_service.dart';
import 'package:babel_novel/utils/theme_colors.dart';

class GenresPage extends ConsumerWidget {
  const GenresPage({super.key});

  static const routeName = 'Genres';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Genres',
        ),
      ),
      body: FutureBuilder(
        future: NovelService.getGenres(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => NovelListScreen(
                          listId: snapshot.data![index],
                          provider: ref.read(
                            novelsByGenreProvider(snapshot.data![index]),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeColors.teal,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        snapshot.data![index],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const ErrorDisplayWidget(message: 'Unable to fetch genres');
          }
        },
      ),
    );
  }
}

class CustomGridDelegate extends SliverGridDelegate {
  CustomGridDelegate({required this.dimension});

  // This is the desired height of each row (and width of each square).
  // When there is not enough room, we shrink this to the width of the scroll view.
  final double dimension;

  // The layout is two rows of squares, then one very wide cell, repeat.

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Determine how many squares we can fit per row.
    int count = constraints.crossAxisExtent ~/ dimension;
    if (count < 1) {
      count = 1; // Always fit at least one regardless.
    }
    final double squareDimension = constraints.crossAxisExtent / count;
    return const SliverGridRegularTileLayout(
        crossAxisCount: 2,
        mainAxisStride: 20,
        crossAxisStride: 20,
        childMainAxisExtent: 100,
        childCrossAxisExtent: 100,
        reverseCrossAxis: false);
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    throw true;
  }
}
