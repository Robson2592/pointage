import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://unregretting-ami-stealthless.ngrok-free.dev/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
    },
  ));

  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> login(String email, String password) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    
    if (response.data['access_token'] != null) {
      await _storage.write(key: 'token', value: response.data['access_token']);
    }
    
    return response;
  }

  Future<Response> register(String name, String email, String password, String confirmPassword) async {
    final response = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    });

    if (response.data['access_token'] != null) {
      await _storage.write(key: 'token', value: response.data['access_token']);
    }

    return response;
  }

  Future<Response> clock(String type, String method, {double? lat, double? lng}) async {
    return await _dio.post('/clocking', data: {
      'type': type,
      'method': method,
      'latitude': lat,
      'longitude': lng,
    });
  }

  Future<Response> logout() async {
    final response = await _dio.post('/logout');
    await _storage.delete(key: 'token');
    return response;
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final response = await _dio.get('/user');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Response> getHistory() async {
    return await _dio.get('/history');
  }

  Future<Response> getStats() async {
    return await _dio.get('/stats');
  }

  Future<Response> getMeStatus() async {
    return await _dio.get('/me-status');
  }

  // Admin Methods
  Future<Response> getEmployees() async {
    return await _dio.get('/admin/employees');
  }

  Future<Response> getEmployeeHistory(String userId) async {
    return await _dio.get('/admin/employees/$userId/history');
  }

  Future<Response> getGlobalStats() async {
    return await _dio.get('/admin/stats');
  }

  Future<Response> getTasks() async {
    return await _dio.get('/tasks');
  }

  Future<Response> createTask(String title, String description) async {
    return await _dio.post('/tasks', data: {
      'title': title,
      'description': description,
    });
  }

  Future<Response> updateTaskStatus(String taskId, String status) async {
    return await _dio.patch('/tasks/$taskId/status', data: {'status': status});
  }

  Future<Response> getSchedules() async {
    return await _dio.get('/schedules');
  }
}
