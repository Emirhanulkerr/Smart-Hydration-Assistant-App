// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 1;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      dailyGoal: fields[0] as int,
      weight: fields[1] as int,
      notificationsEnabled: fields[2] as bool,
      notificationIntervalMinutes: fields[3] as int,
      selectedTheme: fields[4] as String,
      selectedCupIcon: fields[5] as String,
      defaultCupSize: fields[6] as int,
      adaptiveNotifications: fields[7] as bool,
      userName: fields[8] as String?,
      wakeUpHour: fields[9] as int,
      sleepHour: fields[10] as int,
      onboardingCompleted: fields[11] as bool,
      selectedColorIndex: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.dailyGoal)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.notificationIntervalMinutes)
      ..writeByte(4)
      ..write(obj.selectedTheme)
      ..writeByte(5)
      ..write(obj.selectedCupIcon)
      ..writeByte(6)
      ..write(obj.defaultCupSize)
      ..writeByte(7)
      ..write(obj.adaptiveNotifications)
      ..writeByte(8)
      ..write(obj.userName)
      ..writeByte(9)
      ..write(obj.wakeUpHour)
      ..writeByte(10)
      ..write(obj.sleepHour)
      ..writeByte(11)
      ..write(obj.onboardingCompleted)
      ..writeByte(12)
      ..write(obj.selectedColorIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

