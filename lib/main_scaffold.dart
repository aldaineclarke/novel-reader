import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({required this.child, super.key});
  final Widget child;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<String> _routes = ['/', '/genres', '/shelf', '/menu'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    GoRouter.of(context).go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.amber,
        unselectedLabelStyle: const TextStyle(color: Colors.black38),
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
