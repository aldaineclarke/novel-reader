import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      children: [
        Text('Menu', style: Theme.of(context).textTheme.headlineLarge),
      ],
    );
  }
}
