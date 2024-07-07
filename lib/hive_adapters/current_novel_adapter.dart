import 'package:hive/hive.dart';
import 'package:novel_reader/providers/current_novel_provider.dart';

class CurrentNovelAdapter extends TypeAdapter<CurrentNovel> {
  @override
  final typeId = 0;

  @override
  CurrentNovel read(BinaryReader reader) {
    return CurrentNovel(
      novelTitle: reader.readString(),
      novelId: reader.readString(),
      novelImage: reader.readString(),
      author: reader.readString(),
      description: reader.readString(),
      genres: reader.readList().cast<String>(),
      currentChapterId: reader.readString(),
      chapterCount: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CurrentNovel obj) {
    //Cascade notation
    writer
      ..writeString(obj.novelTitle)
      ..writeString(obj.novelId)
      ..writeString(obj.novelImage)
      ..writeList(obj.genres)
      ..writeString(obj.author)
      ..writeString(obj.description)
      ..writeString(obj.currentChapterId)
      ..writeInt(obj.chapterCount);
  }
}
