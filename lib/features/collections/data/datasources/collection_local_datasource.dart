import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../models/collection_model.dart';

abstract class CollectionLocalDataSource {
  Future<List<CollectionModel>> getAllCollections();
  Future<CollectionModel> getCollectionById(String id);
  Future<CollectionModel> createCollection(String name, String? description);
  Future<CollectionModel> updateCollection(CollectionModel collection);
  Future<void> deleteCollection(String id);
  Future<void> incrementLinkCount(String collectionId);
  Future<void> decrementLinkCount(String collectionId);
}

class CollectionLocalDataSourceImpl implements CollectionLocalDataSource {
  static const String _collectionsKey = 'collections_cache';
  final SharedPreferences sharedPreferences;
  final Uuid uuid = const Uuid();
  
  // In-memory cache
  Map<String, CollectionModel>? _cache;

  CollectionLocalDataSourceImpl(this.sharedPreferences);

  Future<Map<String, CollectionModel>> _getCache() async {
    if (_cache != null) return _cache!;
    
    try {
      final jsonString = sharedPreferences.getString(_collectionsKey);
      if (jsonString == null || jsonString.isEmpty) {
        _cache = {};
        return _cache!;
      }
      
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cache = jsonMap.map((key, value) => 
        MapEntry(key, CollectionModel.fromJson(value as Map<String, dynamic>))
      );
      return _cache!;
    } catch (e) {
      _cache = {};
      return _cache!;
    }
  }

  Future<void> _saveCache(Map<String, CollectionModel> cache) async {
    try {
      final jsonMap = cache.map((key, value) => 
        MapEntry(key, value.toJson())
      );
      final jsonString = json.encode(jsonMap);
      await sharedPreferences.setString(_collectionsKey, jsonString);
      _cache = cache;
    } catch (e) {
      throw CacheException('Failed to save cache: $e');
    }
  }

  @override
  Future<List<CollectionModel>> getAllCollections() async {
    try {
      final cache = await _getCache();
      final collections = cache.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return collections;
    } catch (e) {
      throw CacheException('Failed to get collections: $e');
    }
  }

  @override
  Future<CollectionModel> getCollectionById(String id) async {
    try {
      final cache = await _getCache();
      final collection = cache[id];
      if (collection == null) {
        throw CacheException('Collection not found');
      }
      return collection;
    } catch (e) {
      throw CacheException('Failed to get collection: $e');
    }
  }

  @override
  Future<CollectionModel> createCollection(String name, String? description) async {
    try {
      final cache = await _getCache();
      final now = DateTime.now();
      final collection = CollectionModel(
        id: uuid.v4(),
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
        linkCount: 0,
      );
      cache[collection.id] = collection;
      await _saveCache(cache);
      return collection;
    } catch (e) {
      throw CacheException('Failed to create collection: $e');
    }
  }

  @override
  Future<CollectionModel> updateCollection(CollectionModel collection) async {
    try {
      final cache = await _getCache();
      final updated = collection.copyWith(updatedAt: DateTime.now());
      cache[updated.id] = updated;
      await _saveCache(cache);
      return updated;
    } catch (e) {
      throw CacheException('Failed to update collection: $e');
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    try {
      final cache = await _getCache();
      cache.remove(id);
      await _saveCache(cache);
    } catch (e) {
      throw CacheException('Failed to delete collection: $e');
    }
  }

  @override
  Future<void> incrementLinkCount(String collectionId) async {
    try {
      final collection = await getCollectionById(collectionId);
      final updated = collection.copyWith(
        linkCount: collection.linkCount + 1,
        updatedAt: DateTime.now(),
      );
      await updateCollection(updated);
    } catch (e) {
      throw CacheException('Failed to increment link count: $e');
    }
  }

  @override
  Future<void> decrementLinkCount(String collectionId) async {
    try {
      final collection = await getCollectionById(collectionId);
      final updated = collection.copyWith(
        linkCount: collection.linkCount > 0 ? collection.linkCount - 1 : 0,
        updatedAt: DateTime.now(),
      );
      await updateCollection(updated);
    } catch (e) {
      throw CacheException('Failed to decrement link count: $e');
    }
  }
}
