import 'package:dio/dio.dart';
import 'dio_client.dart';

/// API Client for making HTTP requests
/// Add your API endpoints here
class ApiClient {
  final DioClient _dioClient;

  ApiClient(this._dioClient);

  // Example: Get Users
  Future<Response> getUsers() async {
    try {
      final response = await _dioClient.get('/users');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Example: Get User by ID
  Future<Response> getUserById(String id) async {
    try {
      final response = await _dioClient.get('/users/$id');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Example: Create User
  Future<Response> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/users', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Example: Update User
  Future<Response> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/users/$id', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Example: Delete User
  Future<Response> deleteUser(String id) async {
    try {
      final response = await _dioClient.delete('/users/$id');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Add more API endpoints here...
}
