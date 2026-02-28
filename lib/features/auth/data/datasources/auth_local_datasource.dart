import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserId(String userId);
  Future<String?> getCachedUserId();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _userIdKey = 'CACHED_USER_ID';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUserId(String userId) async {
    try {
      await sharedPreferences.setString(_userIdKey, userId);
    } catch (e) {
      throw CacheException('فشل حفظ بيانات المستخدم محلياً');
    }
  }

  @override
  Future<String?> getCachedUserId() async {
    try {
      return sharedPreferences.getString(_userIdKey);
    } catch (e) {
      throw CacheException('فشل جلب بيانات المستخدم المحلية');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_userIdKey);
    } catch (e) {
      throw CacheException('فشل مسح بيانات المستخدم المحلية');
    }
  }
}
