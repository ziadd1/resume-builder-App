
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resume_builder/Services/api_service.dart';
import 'package:resume_builder/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  // Add any required parameters or constructor

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String _email = '';
  String _password = '';
String _error= '';


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await _authService.loginUser(
          authProvider, _email, _password);
      if (result['success']) {
        final userType = result['userType'];
        // Get the AuthProvider instance
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Get the authToken
        final authToken = await authProvider.getAuthToken();

        // Set the authToken in the AuthProvider
        await authProvider.setAuthToken(authToken!);
        // Redirect based on user type
        if (userType == 'user') {
          // Redirect to the home screen and pass the userId
          Navigator.pushNamed(
            context,
            '/home',
            arguments: {'userId': authProvider.userId},
          );
        } else if (userType == 'recruiter') {
          Navigator.pushNamed(context, '/resumes_user');
        } else if (userType == 'admin') {
          //LESA HAGHAYARHA
          Navigator.pushNamed(context, '/chooseAdmin');
        }
        else {
          // Handle login failure
          print('Login failed');

        }

      }
      else {
        // Handle login failure
        setState(() {
          _error = result['error']; // Assuming the error key in the response is 'error'
        });

      }


    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey,
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            //set border radius more than 50% of height and width to make circle
          ),
          color: Colors.white,
          margin: EdgeInsets.all(30),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Theme(
              data: Theme.of(context).copyWith(
                primaryColor: Colors.green,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 16),

                      Text(
                        _error,
                        style: TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signUp_screen');
                        },
                        child: Text(
                          'Don\'t have an account? Sign Up',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}