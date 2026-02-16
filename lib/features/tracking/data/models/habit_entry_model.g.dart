// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitEntryModelAdapter extends TypeAdapter<HabitEntryModel> {
  @override
  final int typeId = 1;

  @override
  HabitEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitEntryModel(
      id: fields[0] as String,
      habitId: fields[1] as String,
      date: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
