class NovelItem {
  NovelItem({
    required this.id,
    required this.title,
    required this.url,
    required this.genres,
    required this.image,
    required this.lastChapter,
  });

  factory NovelItem.fromJson(Map<String, dynamic> json) {
    return NovelItem(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as Iterable<dynamic>)
          : [],
      image: json['image'] as String,
      lastChapter: json['lastChapter'] as String,
    );
  }
  final String id;
  final String title;
  final String url;
  final List<String> genres;
  final String image;
  final String lastChapter;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'genres': genres,
      'image': image,
      'lastChapter': lastChapter,
    };
  }
}
