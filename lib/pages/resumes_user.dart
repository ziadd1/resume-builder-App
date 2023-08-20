import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

class resumes_user extends StatefulWidget {
  @override
  _ResumesUserState createState() => _ResumesUserState();
}

class _ResumesUserState extends State<resumes_user> {
  late Future<List<dynamic>> cvList;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cvList = fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(
      Uri.parse('http://192.168.8.106:4000/api/cv/getCvs'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List<dynamic>) {
        return data;
      } else {
        print('Invalid response body: $data');
      }
    }
    return []; // Return an empty list if the response is not as expected
  }

  Future<List<dynamic>> searchResumes(String query) async {
    if (query.isEmpty) {
      // If the search query is empty, return the initial list of all CVs
      return fetchData();
    }

    final response = await http.get(
      Uri.parse('http://192.168.8.106:4000/api/recruiter/searchResumes?query=$query'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List<dynamic>) {
        return data;
      } else if (data is Map<String, dynamic> && data.containsKey('resumes')) {
        final resumes = data['resumes'];
        if (resumes is List<dynamic>) {
          return resumes;
        }
      }
      print('Invalid search response body: $data');
    }
    return []; // Return an empty list if the response is not as expected
  }

  void performSearch(String query) {
    setState(() {
      cvList = searchResumes(query);
    });
  }

  void navigateToPreviewPage(String resumeId) {
    Navigator.pushNamed(
      context,
      '/preview',
      arguments: {'resumeId': resumeId},
    );
  }


  @override
  void logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login_screen', (route) => false);
  }
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Resumes', style: TextStyle(color: Colors.black)),
    backgroundColor: Colors.grey,
    actions: [
    if (authProvider.isLoggedIn)
    IconButton(
    icon: Icon(Icons.logout),
    onPressed: () => logout(),),
       ],
        ),

    body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    performSearch(searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(

            child: FutureBuilder<List<dynamic>>(
              future: cvList,
              builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cv = snapshot.data![index];
                      final resumeId = cv['_id'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            //set border radius more than 50% of height and width to make circle
                          ),
                          color: Colors.grey[200],

                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(

                              child: Text(
                                cv['Name'][0],
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Colors.grey,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(cv['Name']),
                                SizedBox(height: 8),
                                Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(cv['skills']),
                                Text('Education:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(cv['education']),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.preview),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/preview',
                                  arguments: {'resumeId': resumeId},
                                );
                              },
                            ),

                          ),

                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[400],
    );
  }
}
