
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resume_builder/Services/api_service.dart';
import 'package:resume_builder/auth/auth_provider.dart';

class createAdmin extends StatefulWidget {
  // Add any required parameters or constructor

  @override
  createAdminState createState() => createAdminState();
}

class createAdminState extends State<createAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String _username = '';
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String signupError = await _authService.CreateAdmin(
        authProvider,
        _username,
        _email,
        _password,
      );
      if (signupError.isEmpty) {
// Handle successful signup and navigation
// Get the AuthProvider instance
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // Get the authToken
        final authToken = await authProvider.getAuthToken();

        // Set the authToken in the AuthProvider
        await authProvider.setAuthToken(authToken!);
        // Redirect to the home screen and pass the userId
        Navigator.pushNamed(
          context,
          '/chooseAdmin',

        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Admin Created Successfully'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage = signupError;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Admin',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.grey, // Set the app bar background color to grey
      ),
      backgroundColor: Colors.grey[300], // Set the background color of the Scaffold to grey
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
                // Set the primary color to your desired color
                primaryColor: Colors.green,

              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Username';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _username = value!;
                        },
                      ),
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
                        child: Text('create', style: TextStyle(fontSize:17 ),),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple, // Set the button background color to grey
                        ),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
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
