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

  void updateNovelCurrentChapter(CurrentNovel novel) async {
    final shelf = Hive.box<CurrentNovel>(Env.shelf_db_name);

    // Retrieve all novels from the state with the matching novelId
    final novels = state
        .where((shelfNovel) => shelfNovel.novelId == novel.novelId)
        .toList();

    if (kDebugMode) {
      print(novels.first.currentChapterId);
    }

    // Check if the novel exists in the shelf
    if (novels.isNotEmpty) {
      // Update the currentChapterId for the first matching novel
      final updatedNovel =
          novels.first.copyWith(currentChapterId: novel.currentChapterId);

      // Update the state
      state = [
        for (final n in state)
          if (n.novelId == novel.novelId) updatedNovel else n
      ];

      // Clear the shelf and put the updated state back into it
      await shelf.clear();
      await shelf.putAll({for (var n in state) n.novelId: n});
    }
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
