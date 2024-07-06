import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_reader/pages/genres.dart';
import 'package:novel_reader/pages/home.dart';
import 'package:novel_reader/providers/bottom_navigation_provider.dart';

class MainScaffold extends ConsumerWidget {
  MainScaffold({super.key});

  final List<Widget> _routes = [
    const HomePage(),
    const GenresPage(),
    Container(
      color: Colors.cyanAccent,
    ),
    Container(color: Colors.pinkAccent)
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(bottomNavProvider);

    return Scaffold(
      body: IndexedStack(index: pageIndex, children: _routes),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.amber,
        unselectedLabelStyle: const TextStyle(color: Colors.black38),
        showUnselectedLabels: true,
        currentIndex: pageIndex,
        onTap: (index) {
          ref.read(bottomNavProvider.notifier).setPageIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Genres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shelves),
            label: 'Shelf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
