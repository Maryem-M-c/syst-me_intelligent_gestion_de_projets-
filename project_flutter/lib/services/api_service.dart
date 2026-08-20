import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Récupérer le token stocké
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Supprimer le token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Connexion
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("Status Code : ${response.statusCode}");
    print("Body : ${response.body}");
    print('$baseUrl/login');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data['token']);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Erreur de connexion'};
    }
  }
  // Inscription
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'client',
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await saveToken(data['token']);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Erreur d\'inscription'};
    }
  }

  // Requête GET authentifiée générique
  static Future<dynamic> get(String endpoint) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Requête POST authentifiée générique
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }
  // Requête PUT authentifiée générique
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

    // Requête DELETE authentifiée générique
  static Future<dynamic> delete(String endpoint) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }

  // Déconnexion
  static Future<void> logout() async {
    final token = await getToken();
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    await clearToken();
  }
  // Modifier un projet
static Future<dynamic> updateProjet(
    int id,
    Map<String, dynamic> data
) async {

  return await put(
    'projets/$id',
    data,
  );
}


// Supprimer un projet
static Future<dynamic> deleteProjet(int id) async {

  final token = await getToken();

  final response = await http.delete(
    Uri.parse('$baseUrl/projets/$id'),

    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
// Ajouter un projet
static Future<dynamic> createProjet(
    Map<String, dynamic> data) async {

  return await post(
    'projets',
    data,
  );

}

}