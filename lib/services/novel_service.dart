import 'package:flutterboilerplate/models/models.dart';
import 'package:flutterboilerplate/models/novel_item.dart';
import 'package:flutterboilerplate/utils/http_client.dart';
import 'package:get_it/get_it.dart';

class NovelService {
  // Send un-cached http request
  static Future<List<NovelItem>> getNovelList(String? criteria) async {
    final route = criteria ?? '/latest-release';
    final fullRoute = '/novel-list/$route';
    try {
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>(fullRoute);
      print(response);
      final apiResult = APIResult.fromJson(response.data!);
      final results = apiResult.results.map((data) {
        return NovelItem.fromJson(data as Map<String, dynamic>);
      }).toList();
      // This is used because the API has the structure {results: []}
      // final resultsDynamic = data.cast<String, List<dynamic>>()['results'];

      // Ensure that results is a List<String>
      // final List<LightNovel> results = resultsDynamic!.cast<String>();
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

      print('Data : ${response.data!}');
      final data = response.data!;
      // This is used because the API has the structure {results: []}
      final resultsDynamic = data.cast<String, List<dynamic>>()['results'];

      // Ensure that results is a List<String>
      final List<String> results = resultsDynamic!.cast<String>();
      return results;
    } catch (e) {
      print(e);
      return ["genre1", "genre 2"];
    }
  }
}

class APIResult {
  final List<dynamic> results;

  APIResult({required this.results});

  factory APIResult.fromJson(Map<String, dynamic> json) {
    return APIResult(
      results: json['results'] as List<dynamic>,
    );
  }
}
