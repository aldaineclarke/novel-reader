import 'package:flutter/material.dart';
import 'package:flutterboilerplate/home_tabs/discover.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const routeName = 'Home';

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
