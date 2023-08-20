import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:resume_builder/auth/auth_provider.dart'; // Import the AuthProvider class
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:resume_builder/auth/auth_provider.dart';
import 'package:provider/provider.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<String?> userIdFuture;

  @override
  void initState() {
    super.initState();
    userIdFuture = getUserIdFromToken();
  }

  Future<String?> getUserIdFromToken() async {
    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
    print(userIdFuture);
    return _secureStorage.read(key: 'userId');
  }


  PreferredSizeWidget? buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return AppBar(
            title: RichText(
              text: TextSpan(
                text: 'Resem',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'U',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.grey,
            actions: [
              if (authProvider.isLoggedIn)
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () => logout(), // Call the logout method
                ),
            ],
          );
        },
      ),
    );
  }

  void logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login_screen', (route) => false);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: FutureBuilder<String?>(
          future: getUserIdFromToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final userId = snapshot.data;
              return Stack(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/homepic.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:15.0,top:10),
                    child: RichText(
                      text: TextSpan(

                        children: [
                          TextSpan(
                            style: TextStyle(fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                            text: 'Welcome to Resem',
                          ),
                          TextSpan(
                            text: 'U',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,


                    children: [
                      Center(
                        child: ElevatedButton(

                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/builder',
                              arguments: {'userId': userId},
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top:16.0,bottom:16,right:50,left:50),
                            child: Text(
                              'Create\nResume',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepPurple,
                            shape: StadiumBorder(),


                          ),
                        ),
                      ),
SizedBox(height:20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/user_resumes',
                            arguments: {'userId': userId},
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top:16.0,bottom:16,right:50,left:50),
                          child: Text(
                            'My\nResumes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple,
                          shape: StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
      backgroundColor: Colors.grey,
    );
  }
}


