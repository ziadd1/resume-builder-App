
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:resume_builder/pages/signUp_screen.dart';

import '../User.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../auth/auth_provider.dart';


String hashPassword(String password) {
  final bytes = utf8.encode(password); // Convert password to bytes
  final digest = sha256.convert(bytes); // Hash the bytes using SHA-256
  final hashedPassword = digest.toString(); // Convert the hash to a string
  return hashedPassword;
}


class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Future<Map<String, dynamic>> loginUser(AuthProvider authProvider,String email, String password) async {
    // http://localhost:4000/api/user/login
    // 10.0.2.2
    final apiUrl = 'http://192.168.8.106:4000/api/user/login3';

    try {
      // final hashedPassword = hashPassword(password);

      print({
        'email': email,
        'password': password,
      });
      final data = {
        'email': email,
    'password': password,
  };

      final dataEncode = jsonEncode(data);
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
        Uri.parse(apiUrl),
          headers: headers,
          body: dataEncode
      );
      print(dataEncode);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authToken = responseData['token'];

        final recId = responseData['rec_id'];
        final adminId = responseData['admin_id'];
        final userId = responseData['user_id'];
        final userType = responseData['user_type']; // Assuming user_type is returned from the API
        print(userType);
print(userId);
print(authToken);
        // Store the token and userId in secure storage
        await _secureStorage.write(key: 'authToken', value: authToken);
        await _secureStorage.write(key: 'userId', value: userId);


        // Update the isLoggedIn flag in the AuthProvider

        authProvider.isLoggedIn = true;


        return {'success': true, 'userType': userType}; // Return the user type along with the success flag
      } else {
        // Login failed
        print(response.body);
        final errorMessage = jsonDecode(response.body)['error'];
        return {'success': false,'error': errorMessage };
      }
    } catch (e) {
      print(e);
      return {'success': false ,  'error': 'An error occurred'};
    }
  }

  Future<String> SignUp(AuthProvider authProvider,String username,String email, String password) async {

    final apiUrl = 'http://192.168.8.106:4000/api/user/signup';

    try {
      // final hashedPassword = hashPassword(password);

      print({
        'username': username,
        'email': email,
        'password': password,
      });
      final data = {
        'username': username,
        'email': email,
        'password': password,
      };

      final dataEncode = jsonEncode(data);
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: dataEncode
      );
      print(dataEncode);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authToken = responseData['token'];

        final userId = responseData['user_id'];
        print(userId);
        print(authToken);
        // Store the token and userId in secure storage
        await _secureStorage.write(key: 'authToken', value: authToken);
        await _secureStorage.write(key: 'userId', value: userId);


        // Update the isLoggedIn flag in the AuthProvider

        authProvider.isLoggedIn = true;


        return '';
      } else {
        // Login failed
        print(response.body);
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'];
        return errorMessage; // Return the error message in case of failure

      }
    } catch (e) {
      print(e);
      return 'Sign up failed.Please try again'; // Return a generic error message
    }
  }


  Future<String> CreateRecruiter(AuthProvider authProvider,String username,String email, String password, String companyName) async {

    final apiUrl = 'http://192.168.8.106:4000/api/admin/CreateRecruiterr';

    try {
      // final hashedPassword = hashPassword(password);

      print({
        'username': username,
        'email': email,
        'password': password,
      });
      final data = {
        'username': username,
        'email': email,
        'password': password,
        'companyName': companyName
      };

      final dataEncode = jsonEncode(data);
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: dataEncode
      );
      print(dataEncode);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authToken = responseData['token'];


        print(authToken);
        // Store the token and userId in secure storage
        await _secureStorage.write(key: 'authToken', value: authToken);



        // Update the isLoggedIn flag in the AuthProvider

        authProvider.isLoggedIn = true;


        return '';
      } else {
        // Login failed
        print(response.body);
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'];
        return errorMessage; // Return the error message in case of failure

      }
    } catch (e) {
      print(e);
      return 'Sign up failed.Please try again'; // Return a generic error message
    }
  }

  Future<String> CreateAdmin(AuthProvider authProvider,String username,String email, String password) async {

    final apiUrl = 'http://192.168.8.106:4000/api/admin/CreateAdmin';

    try {
      // final hashedPassword = hashPassword(password);

      print({
        'username': username,
        'email': email,
        'password': password,
      });
      final data = {
        'username': username,
        'email': email,
        'password': password,
      };

      final dataEncode = jsonEncode(data);
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: dataEncode
      );
      print(dataEncode);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authToken = responseData['token'];


        print(authToken);
        // Store the token and userId in secure storage
        await _secureStorage.write(key: 'authToken', value: authToken);



        // Update the isLoggedIn flag in the AuthProvider

        authProvider.isLoggedIn = true;


        return '';
      } else {
        // Login failed
        print(response.body);
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'];
        return errorMessage; // Return the error message in case of failure

      }
    } catch (e) {
      print(e);
      return 'Sign up failed.Please try again'; // Return a generic error message
    }
  }


//   Future<bool> registerUser(User user) async {
//     // Make API call to register endpoint
//     // Return true if registration is successful, false otherwise
//   }
// }
}



