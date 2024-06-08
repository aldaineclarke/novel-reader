import 'package:flutterboilerplate/models/models.dart';
import 'package:flutterboilerplate/utils/http_client.dart';
import 'package:get_it/get_it.dart';

class NovelService {
  // Send un-cached http request
  static Future<List<LightNovel>> getNovels() async {
    final response = await GetIt.I<HttpClient>().get<List<dynamic>>('/posts');
    return response.data!
        .map<LightNovel>((e) => LightNovel.fromJson(e as Map<String, dynamic>))
        .toList();
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
