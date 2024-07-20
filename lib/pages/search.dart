import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:novel_reader/services/novel_service.dart';

class SearchPage extends StatelessWidget {
  SearchPage(
      {this.searchType = SearchType.novelTitle,
      this.searchVal = '',
      super.key});
  SearchType searchType;
  late String searchVal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: NovelService.getNovelList(searchVal),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('No content Just Error'),
            );
          } else {
            return ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(child: Text(snapshot.data![index].title));
                });
          }
        },
      ),
    );
  }
}

enum SearchType { genre, author, novelTitle }
