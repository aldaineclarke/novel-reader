import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'light_novel.freezed.dart';
part 'light_novel.g.dart';

@freezed
class LightNovel with _$LightNovel {
  const factory LightNovel(
      {required String id,
      required String title,
      @Default('https://via.placeholder.com/150/92c952') String image,
      @Default('Unknown') String author,
      required List<String> genres,
      @Default(5) double rating,
      @Default(20) int views,
      @Default('') String lastChapter,
      required String description,
      required String status,
      @Default(0) int pages,
      required List<Map<String, String>> chapters}) = _LightNovel;

  factory LightNovel.fromJson(Map<String, Object?> json) =>
      _$LightNovelFromJson(json);
}
