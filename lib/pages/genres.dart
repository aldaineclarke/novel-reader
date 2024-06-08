import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterboilerplate/services/novel_service.dart';

class GenresPage extends StatelessWidget {
  const GenresPage({super.key});

  static const routeName = 'Genres';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Genres"),
      ),
      body: FutureBuilder(
        future: NovelService.getGenres(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 207, 149, 24),
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      snapshot.data![index],
                    ),
                  ),
                );
              },
            );
          } else {
            return Text("No Content");
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
    return SliverGridRegularTileLayout(
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
