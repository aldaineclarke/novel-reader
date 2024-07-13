import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:novel_reader/env.dart';
import 'package:novel_reader/hive_adapters/current_novel.dart';

class ShelfNotifier extends StateNotifier<List<CurrentNovel>> {
  ShelfNotifier() : super([]) {
    _loadShelf();
  }

  Future<void> _loadShelf() async {
    final shelf = await Hive.openBox<CurrentNovel>(Env.shelf_db_name);
    state = shelf.values.toList();
  }

  void addNovelToShelf(CurrentNovel novel) async {
    final shelf = Hive.box<CurrentNovel>(Env.shelf_db_name);
    await shelf.add(novel);
    state = [...state, novel];
  }

  // Finds the novel in the shelf and return true if it is present;
  bool novelInShelf(CurrentNovel novel) {
    final novels =
        state.where((shelfNovel) => shelfNovel.novelId == novel.novelId);
    if (kDebugMode) {
      print(novels);
      print('Novel On Shelf:  ${novels.isNotEmpty}');
    }
    return novels.isNotEmpty;
  }

  void clearShelf() async {
    final shelf = Hive.box<CurrentNovel>(Env.shelf_db_name);
    await shelf.clear();
    state = [];
  }

  void removeFromShelf(int index) async {
    final shelf = Hive.box<CurrentNovel>(Env.shelf_db_name);
    await shelf.deleteAt(index);
    state = shelf.values.toList();
  }
}

// Provider for the ShelfNotifier
final shelfProvider =
    StateNotifierProvider<ShelfNotifier, List<CurrentNovel>>((ref) {
  return ShelfNotifier();
});
