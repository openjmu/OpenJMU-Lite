// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beans.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseAdapter extends TypeAdapter<Course> {
  @override
  final typeId = 2;

  @override
  Course read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Course(
      isCustom: fields[0] as bool,
      name: fields[1] as String,
      time: fields[2] as String,
      location: fields[3] as String,
      className: fields[4] as String,
      teacher: fields[5] as String,
      day: fields[6] as int,
      startWeek: fields[7] as int,
      endWeek: fields[8] as int,
      classesName: (fields[10] as List)?.cast<String>(),
      isEleven: fields[11] as bool,
      oddEven: fields[9] as int,
      rawDay: fields[12] as int,
      rawTime: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Course obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.isCustom)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.className)
      ..writeByte(5)
      ..write(obj.teacher)
      ..writeByte(6)
      ..write(obj.day)
      ..writeByte(7)
      ..write(obj.startWeek)
      ..writeByte(8)
      ..write(obj.endWeek)
      ..writeByte(9)
      ..write(obj.oddEven)
      ..writeByte(10)
      ..write(obj.classesName)
      ..writeByte(11)
      ..write(obj.isEleven)
      ..writeByte(12)
      ..write(obj.rawDay)
      ..writeByte(13)
      ..write(obj.rawTime);
  }
}

class ScoreAdapter extends TypeAdapter<Score> {
  @override
  final typeId = 3;

  @override
  Score read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Score(
      code: fields[0] as String,
      courseName: fields[1] as String,
      score: fields[2] as String,
      termId: fields[3] as String,
      credit: fields[4] as double,
      creditHour: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Score obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.termId)
      ..writeByte(4)
      ..write(obj.credit)
      ..writeByte(5)
      ..write(obj.creditHour);
  }
}

class WebAppAdapter extends TypeAdapter<WebApp> {
  @override
  final typeId = 4;

  @override
  WebApp read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WebApp(
      appId: fields[0] as int,
      sequence: fields[1] as int,
      code: fields[2] as String,
      name: fields[3] as String,
      url: fields[4] as String,
      menuType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WebApp obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.appId)
      ..writeByte(1)
      ..write(obj.sequence)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.menuType);
  }
}
