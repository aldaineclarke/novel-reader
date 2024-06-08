// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'light_novel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LightNovelImpl _$$LightNovelImplFromJson(Map<String, dynamic> json) =>
    _$LightNovelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      image:
          json['image'] as String? ?? 'https://via.placeholder.com/150/92c952',
      author: json['author'] as String? ?? 'Unknown',
      genres:
          (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5,
      views: (json['views'] as num?)?.toInt() ?? 20,
      lastChapter: json['lastChapter'] as String? ?? '',
      description: json['description'] as String,
      status: json['status'] as String,
      pages: (json['pages'] as num?)?.toInt() ?? 0,
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
    );

Map<String, dynamic> _$$LightNovelImplToJson(_$LightNovelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image': instance.image,
      'author': instance.author,
      'genres': instance.genres,
      'rating': instance.rating,
      'views': instance.views,
      'lastChapter': instance.lastChapter,
      'description': instance.description,
      'status': instance.status,
      'pages': instance.pages,
      'chapters': instance.chapters,
    };
