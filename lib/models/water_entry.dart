import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'water_entry.g.dart';

@HiveType(typeId: 0)
class WaterEntry extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int amount; // ml cinsinden

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? note;

  const WaterEntry({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  factory WaterEntry.create({
    required int amount,
    String? note,
  }) {
    return WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: DateTime.now(),
      note: note,
    );
  }

  WaterEntry copyWith({
    String? id,
    int? amount,
    DateTime? timestamp,
    String? note,
  }) {
    return WaterEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, amount, timestamp, note];
}

