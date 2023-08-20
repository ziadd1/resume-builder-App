// import 'dart:html';
// import 'dart:js';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:resume_builder/pages/preview.dart';
//
// class ProfilePictureUploadPage extends StatelessWidget {
//   final String resumeId;
//
//   ProfilePictureUploadPage({required this.resumeId});
//
//   Future<void> _uploadProfilePicture(File image) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('your-backend-url/uploadImage/$resumeId'),
//     );
//     request.files.add(await http.MultipartFile.fromPath('profilePicture', image.path));
//     var response = await request.send();
//     if (response.statusCode == 200) {
//       // Successfully uploaded image
//       // Navigate to Template1 page passing the resumeId
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Template1(resumeId: resumeId),
//         ),
//       );
//     } else {
//       // Handle upload error
//       // Display an error message or take appropriate action
//     }
//   }
//
// // ... Implement image selection and upload UI
//
// // Call _uploadProfilePicture() when the user presses the "Next" button
// }
//
