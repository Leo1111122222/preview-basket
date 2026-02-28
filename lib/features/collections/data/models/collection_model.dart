import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/collection.dart';

class CollectionModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int linkCount;
  final String? userId;
  final bool isLocked;
  final String? lockPin;

  CollectionModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.linkCount = 0,
    this.userId,
    this.isLocked = false,
    this.lockPin,
  });

  Collection toEntity() {
    return Collection(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      linkCount: linkCount,
      isLocked: isLocked,
      lockPin: lockPin,
    );
  }

  factory CollectionModel.fromEntity(Collection collection) {
    return CollectionModel(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
      linkCount: collection.linkCount,
    );
  }

  // From Firestore
  factory CollectionModel.fromFirestore(Map<String, dynamic> data) {
    return CollectionModel(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      linkCount: data['linkCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      userId: data['userId'] as String?,
      isLocked: data['isLocked'] as bool? ?? false,
      lockPin: data['lockPin'] as String?,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'linkCount': linkCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
      'isLocked': isLocked,
      'lockPin': lockPin,
    };
  }

  // To JSON (for SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'linkCount': linkCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'isLocked': isLocked,
      'lockPin': lockPin,
    };
  }

  // From JSON (for SharedPreferences)
  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      linkCount: json['linkCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      lockPin: json['lockPin'] as String?,
    );
  }

  CollectionModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? linkCount,
    String? userId,
    bool? isLocked,
    String? lockPin,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      linkCount: linkCount ?? this.linkCount,
      userId: userId ?? this.userId,
      isLocked: isLocked ?? this.isLocked,
      lockPin: lockPin ?? this.lockPin,
    );
  }
}
