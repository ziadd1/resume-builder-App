import 'package:flutter/material.dart';
import 'package:resume_builder/pages/chooseAdmin.dart';
import 'package:resume_builder/pages/createAdmin.dart';
import 'package:resume_builder/pages/createRecruiter.dart';
import 'package:resume_builder/pages/home.dart';
import 'package:resume_builder/pages/builder.dart';
import 'package:resume_builder/pages/signUp_screen.dart';
import 'package:resume_builder/pages/user_resumes.dart';
import 'package:resume_builder/pages/preview.dart';
import 'package:resume_builder/pages/login_screen.dart';

import 'package:resume_builder/pages/resumes_user.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:resume_builder/auth/auth_provider.dart'; // Import the AuthProvider class


void main() => runApp(
      ChangeNotifierProvider(
            create: (_) => AuthProvider(), // Provide an instance of AuthProvider
            child: MyApp(),
      ),
);


class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
            return Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                        return MaterialApp(
                              title: 'Resume Builder',
                              initialRoute: authProvider.isLoggedIn ? '/home' : '/login_screen',
                              routes: {
                                    '/home': (context) => Home(),
                                    '/builder': (context) => builder(),
                                    '/user_resumes': (context) => user_resumes(),
                                    '/preview': (context) => preview(),
                                    '/login_screen': (context) => LoginScreen(),
                                    '/signUp_screen': (context) => SignUp(),
                                    '/resumes_user': (context) => resumes_user(),
                                    '/chooseAdmin': (context) => chooseAdmin(),
                                    '/createAdmin': (context) => createAdmin(),
                                    '/createRecruiter': (context) => createRecruiter(),
                              },
                        );
                  },
            );
      }
}







