// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_list_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterListItemAdapter extends TypeAdapter<ChapterListItem> {
  @override
  final int typeId = 1;

  @override
  ChapterListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterListItem(
      id: fields[0] as String,
      title: fields[1] as String,
      url: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterListItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
