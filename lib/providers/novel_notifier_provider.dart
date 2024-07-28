import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:novel_reader/models/novel_item.dart';
import 'package:novel_reader/services/novel_service.dart';
import 'package:novel_reader/utils/http_client.dart';

class NovelsNotifier extends StateNotifier<List<NovelItem>> {
  NovelsNotifier(this.apiUrl) : super([]) {
    fetchNovels();
  }

  final String apiUrl;
  int _page = 1;
  bool _isFetching = false;

  void addNovels(List<NovelItem> newNovelItems) {
    state = [...state, ...newNovelItems];
    _page++;
  }

  Future<void> fetchNovels() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final fullRoute = '/novel-list/$apiUrl/page/$_page';
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>(fullRoute);
      final apiResult = APIResult.fromJson(response.data!);
      final newNovelItems = apiResult.results.map((data) {
        return NovelItem.fromJson(data as Map<String, dynamic>);
      }).toList();

      state = [...state, ...newNovelItems];
      _page++;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refreshList() async {
    if (_isFetching) return;
    _isFetching = true;
    _page = 1;
    try {
      final fullRoute = '/novel-list/$apiUrl/page/$_page';
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>(fullRoute);
      final apiResult = APIResult.fromJson(response.data!);
      final newNovelItems = apiResult.results.map((data) {
        return NovelItem.fromJson(data as Map<String, dynamic>);
      }).toList();

      state = [...newNovelItems];
      _page++;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      _isFetching = false;
    }
  }
}

final latestReleasesProvider =
    StateNotifierProvider<NovelsNotifier, List<NovelItem>>(
  (ref) => NovelsNotifier('latest-release'),
);

final completedNovelsProvider =
    StateNotifierProvider<NovelsNotifier, List<NovelItem>>(
  (ref) => NovelsNotifier('complete-novels'),
);

final mostPopularNovelsProvider =
    StateNotifierProvider<NovelsNotifier, List<NovelItem>>(
  (ref) => NovelsNotifier('most-popular'),
);

final newNovelsProvider =
    StateNotifierProvider<NovelsNotifier, List<NovelItem>>(
  (ref) => NovelsNotifier('new-novels'),
);

final novelsByGenreProvider = Provider.family<
    StateNotifierProvider<NovelsNotifier, List<NovelItem>>, String>(
  (ref, genreName) {
    return StateNotifierProvider<NovelsNotifier, List<NovelItem>>((ref) {
      return NovelsNotifier(genreName);
    });
  },
);

StateNotifierProvider<NovelsNotifier, List<NovelItem>> getNovelProvider(
    String novelList) {
  switch (novelList) {
    case 'complete-novels':
      return completedNovelsProvider;

    case 'most-popular':
      return mostPopularNovelsProvider;

    case 'new-novels':
      return newNovelsProvider;

    case 'latest-release':
      return latestReleasesProvider;

    default:
      // You can throw an exception or return a default provider
      throw Exception('Unknown novel list type: $novelList');
  }
}
