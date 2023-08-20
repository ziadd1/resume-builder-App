import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:resume_builder/auth/auth_provider.dart'; // Import the AuthProvider class
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:resume_builder/auth/auth_provider.dart';
import 'package:provider/provider.dart';


class chooseAdmin extends StatefulWidget {
  const chooseAdmin({Key? key}) : super(key: key);

  @override
  State<chooseAdmin> createState() => _chooseAdminState();
}

class _chooseAdminState extends State<chooseAdmin> {
  late Future<String?> userIdFuture;

  @override





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

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {

              return Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
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
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: Offset(0, -140),
                        child: RichText(
                          text: TextSpan(

                            children: [
                              TextSpan(
                                style: TextStyle(fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                                text: 'Welcome to Resem',
                              ),
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
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 200.0,
                          left: 200,
                          right: 20,
                          top: 150,
                        ),
                        child: SizedBox(
                          width: 220,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/createRecruiter',

                              );
                            },
                            child: Text(
                              'Create Recruiter',
                              textAlign: TextAlign.center,
                              style: TextStyle(

                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepPurple,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 200.0,
                          right: 200,
                          left: 20,
                          top: 150,
                        ),
                        child: SizedBox(
                          width: 155,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/createAdmin',

                              );
                            },
                            child: Text(
                              'Create Admin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepPurple,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ),
                      ),
                    ),
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