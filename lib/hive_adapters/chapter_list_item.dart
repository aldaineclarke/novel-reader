import 'package:hive/hive.dart';
part 'chapter_list_item.g.dart';

@HiveType(typeId: 1)
class ChapterListItem {
  ChapterListItem({required this.id, required this.title, required this.url});

  factory ChapterListItem.fromJson(Map<String, dynamic> json) {
    return ChapterListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }

  ChapterListItem copyWith({String? id, String? title, String? url}) {
    return ChapterListItem(
        id: id ?? this.id, title: title ?? this.title, url: url ?? this.url);
  }

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String url;
}
