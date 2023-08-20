import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class builder extends StatefulWidget {
  const builder({Key? key}) : super(key: key);

  @override
  State<builder> createState() => _builderState();
}

class _builderState extends State<builder> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _referencesController = TextEditingController();
  final _employmentHistoryController = TextEditingController();
  final _skillsController = TextEditingController();
  final _educationController = TextEditingController();
  final _profileController = TextEditingController();
  final _templateController = TextEditingController();

  String selectedTemplate = 'template1';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _referencesController.dispose();
    _employmentHistoryController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _profileController.dispose();
    _templateController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return
             AppBar(
                title: Text('Enter your info',style:TextStyle(
                    color: Colors.black

                )),
                backgroundColor:Colors.grey,

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


    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return  Scaffold(
      appBar: buildAppBar(),
    body: Padding(
      padding: const EdgeInsets.all(16.0),

    child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text('Please seperate using a comma',style:TextStyle(fontSize: 20, color: Colors.grey[800],  ), ),
        Divider(),

        Text('Name',style:TextStyle(fontSize: 25)),
      TextField(

        controller: _nameController,
        decoration: InputDecoration(
          hintText: 'Enter your name',
        ),
      ),
      SizedBox(height: 16),
      Text('Phone',style:TextStyle(fontSize: 25)),
      TextField(
        controller: _phoneController,
        decoration: InputDecoration(
          hintText: 'Enter your phone number',
        ),
      ),
      SizedBox(height: 16),
      Text('Email',style:TextStyle(fontSize: 25)),
      TextField(
        controller: _emailController,
        decoration: InputDecoration(
          hintText: 'Enter your email',
        ),
      ),
          SizedBox(height: 16),
          Text('Address',style:TextStyle(fontSize: 25)),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Enter your address',
            ),
          ),
      SizedBox(height: 16),
      Text('Experiences',style:TextStyle(fontSize: 25)),
      TextField(
        controller: _referencesController,
        decoration: InputDecoration(
          hintText: 'Enter your experiences',
        ),
      ),
      SizedBox(height: 16),
      Text('Employment History',style:TextStyle(fontSize: 25)),
      TextField(
        controller: _employmentHistoryController,
        decoration: InputDecoration(
          hintText: 'Enter your employment history',
        ),
      ),
      SizedBox(height: 16),
      Text('Skills',style:TextStyle(fontSize: 25)),
      TextField(
        controller: _skillsController,
        decoration: InputDecoration(
          hintText: 'Enter your skills',
        ),
      ),
      SizedBox(height: 16),
      Text('Education',style:TextStyle(fontSize: 25)),
      TextField(
        controller: _educationController,
        decoration: InputDecoration(
          hintText: 'Enter your education',
        ),
      ),
      SizedBox(height: 16),
      Text('Profile',style:TextStyle(fontSize: 25)),
      TextField(
        controller: _profileController,
        decoration: InputDecoration(
          hintText: 'Enter your profile',
        ),
      ),

          const Text('Select a template',style:TextStyle(fontSize: 25)),
          DropdownButton<String>(
            dropdownColor: Colors.grey[300],
            underline: Container(
              height: 2,
              color: Colors.grey[500],
            ),
            value: selectedTemplate,
            onChanged: (String? newValue) {
              setState(() {
                selectedTemplate = newValue!;
              });
            },
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'template1',
                child: Text('Simple white'),
              ),
              DropdownMenuItem<String>(
                value: 'template2',
                child: Text('Blue and white'),
              ),
              DropdownMenuItem<String>(
                value: 'template3',
                child: Text('Grey and white'),
              ),
            ],
          ),


          SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.deepPurple,
          shape: StadiumBorder(),
        ),
    onPressed: () async {
      final String userId = args['userId'];

      final name = _nameController.text;
      final phone = _phoneController.text;
      final address = _addressController.text;
      final email = _emailController.text;
      final references = _referencesController.text;
      final employmentHistory = _employmentHistoryController.text;
      final skills = _skillsController.text;
      final education = _educationController.text;
      final profile = _profileController.text;
      final template = selectedTemplate;
      // Call the backend API to create the resume
      final url = 'http://192.168.8.106:4000/api/cv/createCv/:userId=$userId';
      //
      final data = {
        'Name': name,
        'phone': phone,
        'address': address,
        'email': email,
        'references': references,
        'EmploymentHistory': employmentHistory,
        'skills': skills,
        'education': education,
        'profile': profile,
        'template': selectedTemplate ?? 'template1',
      };
print(data);
      print(name);
      final dataEncode = jsonEncode(data);
      print(dataEncode);

      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(Uri.parse(url), headers: headers, body: dataEncode);
      print(response.body);

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON response and navigate to the next page
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final resumeId = responseData['_id'];

        print(resumeId);
        Navigator.pushNamed(context, '/preview', arguments: {'resumeId': resumeId},);
      } else {
        // If the server did not return a 200 OK response,
        // then show an error message
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to create the resume'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    },
        child: Text('Create Resume'),

      ),
        ],
    ),
    ),
    ),
      backgroundColor: Colors.grey[300],
    );











  }
}
