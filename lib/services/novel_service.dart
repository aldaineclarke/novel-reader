import 'package:novel_reader/models/chapter_data.dart';
import 'package:novel_reader/models/models.dart';
import 'package:novel_reader/models/novel_item.dart';
import 'package:novel_reader/utils/http_client.dart';
import 'package:get_it/get_it.dart';

class NovelService {
  // Send un-cached http request
  static Future<List<NovelItem>> getNovelList(String? criteria,
      [int? page = 1]) async {
    final route = criteria ?? '/latest-release';
    final fullRoute = '/novel-list/$route/page/$page';
    try {
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>(fullRoute);
      final apiResult = APIResult.fromJson(response.data!);
      final results = apiResult.results.map((data) {
        return NovelItem.fromJson(data as Map<String, dynamic>);
      }).toList();
      return results;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<String>> getGenres() async {
    try {
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>('/genres');
      final data = response.data!;
      // This is used because the API has the structure {results: []}
      final resultsDynamic = data.cast<String, List<dynamic>>()['results'];
      // Ensure that results is a List<String>
      final results = resultsDynamic!.cast<String>();
      return results;
    } catch (e) {
      print(e);
      return ["genre1", "genre 2"];
    }
  }

  static Future<LightNovel> getNovelInfo(String novelId,
      [int? chapterPage]) async {
    try {
      var url = '/info?id=$novelId';
      if (chapterPage != null) {
        url += '&chapterPage=$chapterPage';
      }
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>(url);
      if (response.data == null) throw Exception('No novel found');
      final lightNovel = LightNovel.fromJson(response.data!);
      return lightNovel;
    } catch (e) {
      return const LightNovel(
          id: 'id',
          title: 'title',
          genres: [],
          description: 'description',
          status: 'status',
          chapters: []);
    }
  }

  static Future<List<NovelItem>> searchNovel(
    String searchText, [
    int? page = 1,
  ]) async {
    final fullRoute = '/search?query=$searchText&page=$page';
    if (searchText == '') {
      return [];
    }
    ;
    try {
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>(fullRoute);
      final apiResult = APIResult.fromJson(response.data!);
      final results = apiResult.results.map((data) {
        return NovelItem.fromJson(data as Map<String, dynamic>);
      }).toList();
      return results;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<ChapterData> getNovelChapter(String chapterId) async {
    try {
      final response = await GetIt.I<HttpClient>()
          .get<Map<String, dynamic>>('/read?chapterId=$chapterId');
      if (response.data == null) throw Exception('No novel found');
      var chapterData = ChapterData.fromJson(response.data!);
      return chapterData;
    } catch (e) {
      print(e);
      return ChapterData(
        text: 'No Data',
        chapterTitle: 'Dummy text',
        novelTitle: 'Novel Data',
      );
    }
  }
}

class APIResult {
  APIResult({required this.results});

  factory APIResult.fromJson(Map<String, dynamic> json) {
    return APIResult(
      results: json['results'] as List<dynamic>,
    );
  }
  final List<dynamic> results;
}
