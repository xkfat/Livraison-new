import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../dataproviders/exception.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Android Emulator IP
  // Use 'http://127.0.0.1:8000/api' for iOS Simulator

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'), // Adjust to your Django auth endpoint
        body: {
          'username': email, // Django usually takes username, not email by default
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw UnauthorisedException('Email ou mot de passe incorrect');
      }
    } on SocketException {
      throw FetchDataException('Pas de connexion internet');
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }
}