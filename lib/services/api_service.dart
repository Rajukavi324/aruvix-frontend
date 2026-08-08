import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://aaruvix-backend.onrender.com";
  static const String authUrl = "$baseUrl/api/auth";
  static const String reportUrl = "$baseUrl/api/reports";
  static const String alertUrl = "$baseUrl/api/alerts";
  static const String exploreUrl = "$baseUrl/api/explore";

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$authUrl/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to send OTP"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp, {
    String? name,
    String? location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$authUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
          if (name != null) "name": name,
          if (location != null) "location": location,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data["token"]);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Verification failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {"success": false, "message": "No token found, please login again"};
      }

      final response = await http.get(
        Uri.parse("$authUrl/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to load profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> submitReport({
    required String issueType,
    String? description,
    String? location,
    String? contactNumber,
    String? photoBase64,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {"success": false, "message": "No token found, please login again"};
      }

      final response = await http.post(
        Uri.parse(reportUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "issueType": issueType,
          "description": description ?? "",
          "location": location ?? "",
          "contactNumber": contactNumber ?? "",
          "photoBase64": photoBase64,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to submit report"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getMyReports() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {"success": false, "message": "No token found, please login again"};
      }

      final response = await http.get(
        Uri.parse("$reportUrl/my-reports"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to load reports"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getAlerts() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {"success": false, "message": "No token found, please login again"};
      }

      final response = await http.get(
        Uri.parse(alertUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to load alerts"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> dismissAlert(String alertId) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {"success": false, "message": "No token found, please login again"};
      }

      final response = await http.patch(
        Uri.parse("$alertUrl/$alertId/dismiss"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to dismiss alert"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getExploreItems({String? category}) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {"success": false, "message": "No token found, please login again"};
      }

      final uri = category != null
          ? Uri.parse("$exploreUrl?category=$category")
          : Uri.parse(exploreUrl);

      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to load items"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> createExploreItem(Map<String, dynamic> itemData) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {"success": false, "message": "No token found, please login again"};
      }

      final response = await http.post(
        Uri.parse(exploreUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(itemData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to add item"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}