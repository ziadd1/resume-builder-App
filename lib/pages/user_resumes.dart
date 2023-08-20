import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

class user_resumes extends StatefulWidget {
  @override
  _UserResumesPageState createState() => _UserResumesPageState();
}

class _UserResumesPageState extends State<user_resumes> {
  List<dynamic> resumes = [];
  String? userId;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userId == null) {
      final Map<String, dynamic> args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      userId = args['userId'];
      print(userId);
      fetchResumes();
    }
  }

  Future<void> fetchResumes() async {
    final response = await http.get(
        Uri.parse('http://192.168.8.106:4000/api/cv/searchResumesByID/$userId'));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      setState(() {
        resumes = responseBody['resumes'];
      });
    } else {
      // If the server did not return a 200 OK response,
      // then show an error message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch resumes'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  Future<void> deleteResume(String resumeId) async {
    final url = Uri.parse('http://192.168.8.106:4000/api/cv/deleteResume/$resumeId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // Deletion successful
      setState(() {
        // Remove the deleted resume from the list
        resumes.removeWhere((resume) => resume['_id'] == resumeId);
      });
    } else {
      // If the server did not return a 200 OK response,
      // show an error message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to delete resume'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  PreferredSizeWidget? buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return AppBar(
          title: Text('My Resumes', style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          ),),
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
        child: resumes.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
          itemCount: resumes.length,
          itemBuilder: (context, index) {
            final resume = resumes[index];
            final resumeId = resume['_id'];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  //set border radius more than 50% of height and width to make circle
                ),
                color: Colors.grey[400],
                child: ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.preview),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/preview',
                            arguments: {'resumeId': resumeId},
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteResume(resumeId);
                        },
                      ),
                    ],
                  ),
                  title: Text(
                    resume['Name'],
                    style: TextStyle(fontSize: 25),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Text(
                      resume['Name'][0],
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                  ),
                  isThreeLine: true,
                  dense: true,
                  contentPadding: EdgeInsets.all(16.0),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 9.0),


                      Text(
                        resume['email'],
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Skills:',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      Text(
                        '${resume['skills'].split(",").map((skill) => skill.trim()).join("\n")}',
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Education:',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      Text(
                        '${resume['education'].split(",").map((education) => education.trim()).join("\n")}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },

        ),
      ),
      backgroundColor: Colors.grey[500],
    );
  }
}
