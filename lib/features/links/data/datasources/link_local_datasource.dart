import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../models/link_preview_model.dart';

abstract class LinkLocalDataSource {
  Future<List<LinkPreviewModel>> getLinksByCollection(String collectionId);
  Future<LinkPreviewModel> addLink(LinkPreviewModel link);
  Future<void> deleteLink(String id);
  Future<LinkPreviewModel?> getLinkByUrl(String url, String collectionId);
}

class LinkLocalDataSourceImpl implements LinkLocalDataSource {
  static const String _linksKey = 'links_cache';
  final SharedPreferences sharedPreferences;
  final Uuid uuid = const Uuid();
  
  // In-memory cache
  Map<String, LinkPreviewModel>? _cache;

  LinkLocalDataSourceImpl(this.sharedPreferences);

  Future<Map<String, LinkPreviewModel>> _getCache() async {
    if (_cache != null) return _cache!;
    
    try {
      final jsonString = sharedPreferences.getString(_linksKey);
      if (jsonString == null || jsonString.isEmpty) {
        _cache = {};
        return _cache!;
      }
      
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cache = jsonMap.map((key, value) => 
        MapEntry(key, LinkPreviewModel.fromJson(value as Map<String, dynamic>))
      );
      return _cache!;
    } catch (e) {
      _cache = {};
      return _cache!;
    }
  }

  Future<void> _saveCache(Map<String, LinkPreviewModel> cache) async {
    try {
      final jsonMap = cache.map((key, value) => 
        MapEntry(key, value.toJson())
      );
      final jsonString = json.encode(jsonMap);
      await sharedPreferences.setString(_linksKey, jsonString);
      _cache = cache;
    } catch (e) {
      throw CacheException('Failed to save cache: $e');
    }
  }

  @override
  Future<List<LinkPreviewModel>> getLinksByCollection(String collectionId) async {
    try {
      final cache = await _getCache();
      final links = cache.values
          .where((link) => link.collectionId == collectionId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return links;
    } catch (e) {
      throw CacheException('Failed to get links: $e');
    }
  }

  @override
  Future<LinkPreviewModel> addLink(LinkPreviewModel link) async {
    try {
      final cache = await _getCache();
      cache[link.id] = link;
      await _saveCache(cache);
      return link;
    } catch (e) {
      throw CacheException('Failed to add link: $e');
    }
  }

  @override
  Future<void> deleteLink(String id) async {
    try {
      final cache = await _getCache();
      cache.remove(id);
      await _saveCache(cache);
    } catch (e) {
      throw CacheException('Failed to delete link: $e');
    }
  }

  @override
  Future<LinkPreviewModel?> getLinkByUrl(String url, String collectionId) async {
    try {
      final cache = await _getCache();
      return cache.values.firstWhere(
        (link) => link.url == url && link.collectionId == collectionId,
        orElse: () => throw CacheException('Link not found'),
      );
    } catch (e) {
      return null;
    }
  }
}
