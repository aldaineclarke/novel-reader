import 'package:novel_reader/models/models.dart';
import 'package:novel_reader/models/novel_item.dart';
import 'package:novel_reader/utils/http_client.dart';
import 'package:get_it/get_it.dart';

class NovelService {
  // Send un-cached http request
  static Future<List<NovelItem>> getNovelList(String? criteria) async {
    final route = criteria ?? '/latest-release';
    final fullRoute = '/novel-list/$route';
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

  static Future<LightNovel> getNovelInfo(String novelId) async {
    try {
      final response = await GetIt.I<HttpClient>()
          .get<Map<String, dynamic>>('/info?id=$novelId');
      if (response.data == null) throw Exception('No novel found');
      var lightNovel = LightNovel.fromJson(response.data!);
      return lightNovel;
    } catch (e) {
      return LightNovel(
          id: 'id',
          title: 'title',
          genres: [],
          description: 'description',
          status: 'status',
          chapters: []);
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

class ChapterData {
  ChapterData(
      {required this.text,
      required this.chapterTitle,
      required this.novelTitle});

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return ChapterData(
      novelTitle: json['novelTitle'] as String,
      chapterTitle: json['chapterTitle'] as String,
      text: json['text'] as String,
    );
  }
  final String novelTitle;
  final String chapterTitle;
  final String text;
}
