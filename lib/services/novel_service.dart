import 'package:babel_novel/app.dart';
import 'package:babel_novel/models/chapter_data.dart';
import 'package:babel_novel/models/models.dart';
import 'package:babel_novel/models/novel_item.dart';
import 'package:babel_novel/services/error_dialog_service.dart';
import 'package:babel_novel/utils/http_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NovelService {
  // Send un-cached http request
  static Future<List<NovelItem>> getNovelList(String? criteria,
      [int? page = 1]) async {
    final context = navigatorKey.currentContext!;

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
    } on DioException catch (e) {
      ErrorDialogService().showErrorDialog(
        context,
        e.error.toString(),
        () => getNovelList(criteria, page),
      );
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<String>> getGenres() async {
    final context = navigatorKey.currentContext!;

    try {
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>('/genres');
      final data = response.data!;
      // This is used because the API has the structure {results: []}
      final resultsDynamic = data.cast<String, List<dynamic>>()['results'];
      // Ensure that results is a List<String>
      final results = resultsDynamic!.cast<String>();
      return results;
    } on DioException catch (e) {
      ErrorDialogService().showErrorDialog(
        context,
        e.error.toString(),
        () => getGenres(),
      );
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<LightNovel> getNovelInfo(String novelId,
      [int? chapterPage]) async {
    final context = navigatorKey.currentContext!;

    try {
      var url = '/info?id=$novelId';

      if (chapterPage != null) {
        url += '&chapterPage=$chapterPage';
      }
      final response =
          await GetIt.I<HttpClient>().get<Map<String, dynamic>>(url);
      final lightNovel = LightNovel.fromJson(response.data!);
      return lightNovel;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<NovelItem>> searchNovel(
    String searchText, [
    int? page = 1,
  ]) async {
    final context = navigatorKey.currentContext!;

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
    } on DioException catch (e) {
      ErrorDialogService().showErrorDialog(
        context,
        e.error.toString(),
        () => Navigator.of(context).pop(),
      );
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<ChapterData> getNovelChapter(String chapterId) async {
    final context = navigatorKey.currentContext!;
    try {
      final response = await GetIt.I<HttpClient>()
          .get<Map<String, dynamic>>('/read?chapterId=$chapterId');
      if (response.data == null) throw Exception('No novel found');
      var chapterData = ChapterData.fromJson(response.data!);
      return chapterData;
    } on DioException catch (e) {
      ErrorDialogService().showErrorDialog(
        context,
        e.error.toString(),
        () => Navigator.of(context).pop(),
      );
      return ChapterData.fromJson({});
    } catch (e) {
      print(e);
      rethrow;
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
