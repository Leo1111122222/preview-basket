import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class SettingsLocalDataSource {
  Future<String> getThemeMode();
  Future<void> saveThemeMode(String themeMode);
  Future<String> getLanguageCode();
  Future<void> saveLanguageCode(String languageCode);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<String> getThemeMode() async {
    try {
      final themeMode = sharedPreferences.getString(StorageConstants.themeMode);
      return themeMode ?? 'system';
    } catch (e) {
      throw CacheException('Failed to get theme mode');
    }
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    try {
      await sharedPreferences.setString(StorageConstants.themeMode, themeMode);
    } catch (e) {
      throw CacheException('Failed to save theme mode');
    }
  }

  @override
  Future<String> getLanguageCode() async {
    try {
      final languageCode = sharedPreferences.getString(StorageConstants.languageCode);
      return languageCode ?? 'ar';
    } catch (e) {
      throw CacheException('Failed to get language code');
    }
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    try {
      await sharedPreferences.setString(StorageConstants.languageCode, languageCode);
    } catch (e) {
      throw CacheException('Failed to save language code');
    }
  }
}
