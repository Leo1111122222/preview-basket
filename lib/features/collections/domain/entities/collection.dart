import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int linkCount;
  final bool isLocked;
  final String? lockPin;

  const Collection({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.linkCount = 0,
    this.isLocked = false,
    this.lockPin,
  });

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt, linkCount, isLocked, lockPin];
}
