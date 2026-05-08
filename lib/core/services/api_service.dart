import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grow/features/auth/data/models/user_model.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _tokenKey = 'auth_token';

  // ── Token helpers ──────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Auth APIs ──────────────────────────────────────────────────────────────

  /// POST /auth/login
  /// Body: { username, password }
  /// Returns: UserModel on success, throws on failure
  static Future<({UserModel user, String message})> login({
    required String username,
    required String password,
  }) async {
    final response = await _post('/auth/login', {
      'username': username.trim(),
      'password': password.trim(),
    }, requiresAuth: false);

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap, token);
      await saveToken(token);
      return (
        user: user,
        message: response['message'] as String? ?? 'Login successful',
      );
    }

    throw Exception(response['message'] as String? ?? 'Login failed');
  }

  // ── Product APIs ───────────────────────────────────────────────────────────

  /// GET /products
  static Future<Map<String, dynamic>> getProducts() {
    return _get('/products');
  }

  /// GET /products/barcode/:barcode
  static Future<Map<String, dynamic>> getProductByBarcode(String barcode) {
    return _get('/products/barcode/$barcode');
  }

  /// POST /products
  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) {
    return _post('/products', data);
  }

  /// PUT /products/:id
  static Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) {
    return _put('/products/$id', data);
  }

  /// DELETE /products/:id
  static Future<Map<String, dynamic>> deleteProduct(String id) {
    return _delete('/products/$id');
  }

  // ── Parcel APIs ────────────────────────────────────────────────────────────

  /// GET /parcels
  static Future<Map<String, dynamic>> getParcels() {
    return _get('/parcels');
  }

  /// POST /parcels
  static Future<Map<String, dynamic>> createParcel(Map<String, dynamic> data) {
    return _post('/parcels', data);
  }

  /// PUT /parcels/:id/status
  static Future<Map<String, dynamic>> updateParcelStatus(
    String id,
    String status,
  ) {
    return _put('/parcels/$id/status', {'status': status});
  }

  // ── Order APIs ─────────────────────────────────────────────────────────────

  /// GET /orders
  static Future<Map<String, dynamic>> getOrders() {
    return _get('/orders');
  }

  /// POST /orders
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) {
    return _post('/orders', data);
  }

  // ── Internal HTTP helpers ──────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
