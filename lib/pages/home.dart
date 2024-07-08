import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:novel_reader/env.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';
import 'package:novel_reader/home_tabs/discover.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const routeName = 'Home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Box<CurrentNovel> novelBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: TabBar(
          padding: EdgeInsets.zero,
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          tabs: [
            Tab(text: 'Explore'),
            Tab(text: 'New Novels'),
            Tab(text: 'Chinese'),
            Tab(text: 'Korean'),
            Tab(text: 'Western'),
            Tab(text: 'Completed'),
          ],
        ),
        body: TabBarView(
          children: [
            DiscoverTab(),
            Tab(text: 'Tab 3'),
            Tab(text: 'Tab 3'),
            Tab(text: 'Tab 3'),
            Tab(text: 'Tab 3'),
            Tab(text: 'Tab 3'),
          ],
        ),
      ),
    );
  }
}
