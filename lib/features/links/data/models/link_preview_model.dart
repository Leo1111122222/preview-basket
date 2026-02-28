import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/link_preview.dart';

class LinkPreviewModel {
  final String id;
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String collectionId;
  final DateTime createdAt;
  final bool isCached;
  final String? userId;

  LinkPreviewModel({
    required this.id,
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    required this.collectionId,
    required this.createdAt,
    this.isCached = false,
    this.userId,
  });

  LinkPreview toEntity() {
    return LinkPreview(
      id: id,
      url: url,
      title: title,
      description: description,
      imageUrl: imageUrl,
      collectionId: collectionId,
      createdAt: createdAt,
      isCached: isCached,
    );
  }

  factory LinkPreviewModel.fromEntity(LinkPreview link) {
    return LinkPreviewModel(
      id: link.id,
      url: link.url,
      title: link.title,
      description: link.description,
      imageUrl: link.imageUrl,
      collectionId: link.collectionId,
      createdAt: link.createdAt,
      isCached: link.isCached,
    );
  }

  // From Firestore
  factory LinkPreviewModel.fromFirestore(Map<String, dynamic> data) {
    return LinkPreviewModel(
      id: data['id'] as String,
      url: data['url'] as String,
      title: data['title'] as String?,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      collectionId: data['collectionId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] as String?,
      isCached: false,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'collectionId': collectionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  // To JSON (for SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'collectionId': collectionId,
      'createdAt': createdAt.toIso8601String(),
      'isCached': isCached,
      'userId': userId,
    };
  }

  // From JSON (for SharedPreferences)
  factory LinkPreviewModel.fromJson(Map<String, dynamic> json) {
    return LinkPreviewModel(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      collectionId: json['collectionId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCached: json['isCached'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }

  LinkPreviewModel copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    String? imageUrl,
    String? collectionId,
    DateTime? createdAt,
    bool? isCached,
    String? userId,
  }) {
    return LinkPreviewModel(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      isCached: isCached ?? this.isCached,
      userId: userId ?? this.userId,
    );
  }
}
