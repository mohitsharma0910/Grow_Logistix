import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl  = 'http://localhost:3000/api';
  static const String _tokenKey = 'auth_token';

  // ── Token ──────────────────────────────────────────────────────────────────

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

  // ── Product APIs ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getProducts() => _get('/products');

  static Future<Map<String, dynamic>> getProductByBarcode(String barcode) =>
      _get('/products/barcode/$barcode');

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) =>
      _post('/products', data);

  static Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) =>
      _put('/products/$id', data);

  static Future<Map<String, dynamic>> deleteProduct(String id) =>
      _delete('/products/$id');

  // ── Parcel APIs ────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getParcels() => _get('/parcels');

  static Future<Map<String, dynamic>> createParcel(Map<String, dynamic> data) =>
      _post('/parcels', data);

  static Future<Map<String, dynamic>> updateParcelStatus(String id, String status) =>
      _put('/parcels/$id/status', {'status': status});

  // ── Order APIs ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getOrders() => _get('/orders');

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) =>
      _post('/orders', data);

  // ── HTTP helpers ───────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl$path'), headers: await _headers());
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
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
      final res = await http.delete(Uri.parse('$_baseUrl$path'), headers: await _headers());
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
