import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/main_scaffold.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Novel Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScaffold(),
    );
  }
}
