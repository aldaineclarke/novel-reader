// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_novel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentNovelAdapter extends TypeAdapter<CurrentNovel> {
  @override
  final int typeId = 0;

  @override
  CurrentNovel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentNovel(
      novelTitle: fields[0] as String,
      novelId: fields[1] as String,
      novelImage: fields[2] as String,
      genres: (fields[3] as List).cast<String>(),
      author: fields[4] as String,
      description: fields[5] as String,
      currentChapterId: fields[6] as String,
      chapterCount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentNovel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.novelTitle)
      ..writeByte(1)
      ..write(obj.novelId)
      ..writeByte(2)
      ..write(obj.novelImage)
      ..writeByte(3)
      ..write(obj.genres)
      ..writeByte(4)
      ..write(obj.author)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.currentChapterId)
      ..writeByte(7)
      ..write(obj.chapterCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentNovelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
