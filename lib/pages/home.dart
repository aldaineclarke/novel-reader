import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:babel_novel/env.dart';
import 'package:babel_novel/hive_adapters/current_novel.dart';
import 'package:babel_novel/home_tabs/discover.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:babel_novel/utils/theme_colors.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Babel Novels',
        ),
      ),
      body: const DiscoverTab(),
    );
  }
}
