import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/pages/genres.dart';
import 'package:novel_reader/pages/home.dart';
import 'package:novel_reader/pages/menu_screen.dart';
import 'package:novel_reader/pages/shelf.dart';
import 'package:novel_reader/providers/bottom_navigation_provider.dart';
import 'package:novel_reader/utils/theme_colors.dart';

class MainScaffold extends ConsumerWidget {
  MainScaffold({super.key});

  final List<Widget> _routes = [
    const HomePage(),
    const GenresPage(),
    const ShelfScreen(),
    const MenuScreen()
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(bottomNavProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: pageIndex, children: _routes),
          ),
          Positioned(
            height: 60,
            bottom: 10,
            left: 20,
            right: 20,
            child: Material(
              elevation: 10, // Adjust the elevation as needed
              borderRadius: BorderRadius.circular(100),
              clipBehavior: Clip.hardEdge,
              child: Container(
                decoration: const BoxDecoration(
                  // border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                // clipBehavior: Clip.hardEdge,
                child: BottomNavigationBar(
                  elevation: 0, // Set elevation to 0 to avoid double shadow
                  type: BottomNavigationBarType.fixed,
                  unselectedItemColor: Colors.black26,
                  selectedItemColor: Theme.of(context).colorScheme.secondary,
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
