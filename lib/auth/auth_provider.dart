
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../Services/api_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _errorMessage = '';
  String? _authToken;
  String? _userId;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  String get errorMessage => _errorMessage;

  set errorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  String? get authToken => _authToken;

  set authToken(String? value) {
    _authToken = value;
    notifyListeners();
  }

  String? get userId => _userId;

  set userId(String? value) {
    _userId = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Perform login logic
    // ...
    final _authService = AuthService();



    Map<String, dynamic> loginResult = await _authService.loginUser(this,email, password);
    bool loginSuccess = loginResult['success'];
    if (loginSuccess) {
      // Successful login
      isLoggedIn = true;
      errorMessage = '';
    } else {
      // Failed login
      isLoggedIn = false;
      errorMessage = 'Incorrect email or password';
    }

    notifyListeners();

    // Store authToken and userId in secure storage
    await _secureStorage.write(key: 'authToken', value: authToken!);
    await _secureStorage.write(key: 'userId', value: userId!);
  }

  Future<void> logout() async {
    // Perform logout logic
    // ...

    // Update isLoggedIn to false
    isLoggedIn = false;
    errorMessage = '';

    // Clear authToken and userId from secure storage
    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'userId');

  }

  Future<String?> getAuthToken() async {
    if (_authToken != null) {
      // If the authToken is already available, return it
      return _authToken;
    }

    // Retrieve authToken from secure storage
    _authToken = await _secureStorage.read(key: 'authToken');
    return _authToken;
  }
  Future<void> setAuthToken(String authToken) async {
    // Store the authToken in secure storage
    await _secureStorage.write(key: 'authToken', value: authToken);
    _authToken = authToken;
    notifyListeners();
  }
}
//
// class AuthProvider extends ChangeNotifier {
//   bool isLoggedIn = false;
//   String errorMessage = '';
//   String? authToken;
//   String? userId;
//
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//
//   void login(String email, String password) async {
//     final _authService = AuthService();
//
//     bool loginSuccess = await _authService.loginUser(email, password);
//     if (loginSuccess) {
//       // Successful login
//       isLoggedIn = true;
//       errorMessage = '';
//     } else {
//       // Failed login
//       isLoggedIn = false;
//       errorMessage = 'Incorrect email or password';
//     }
//
//     notifyListeners();
//   }
//
//   void logout() {
//     // Update isLoggedIn to false
//     isLoggedIn = false;
//     errorMessage = '';
//
//     // Clear authToken and userId from secure storage
//     _secureStorage.delete(key: 'authToken');
//     _secureStorage.delete(key: 'userId');
//
//     notifyListeners();
//   }
//
//   Future<String?> getAuthToken() async {
//     if (authToken != null) {
//       // If the authToken is already available, return it
//       return authToken;
//     }
//
//     // Retrieve authToken from secure storage
//     authToken = await _secureStorage.read(key: 'authToken');
//     return authToken;
//   }
//
//   Future<void> setAuthToken(String authToken) async {
//     // Store the authToken in secure storage
//     await _secureStorage.write(key: 'authToken', value: authToken);
//     this.authToken = authToken;
//   }
// }
