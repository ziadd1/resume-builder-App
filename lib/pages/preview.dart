import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../auth/auth_provider.dart';

import 'package:image/image.dart' as img;

import 'package:permission_handler/permission_handler.dart';




class preview extends StatefulWidget {
  const preview({Key? key}) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<preview> {
  late String resumeId;
  late Future<Map<String, dynamic>> resumeDataFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    resumeId = args['resumeId'];
    print(resumeId);
    resumeDataFuture = _fetchResumeData().then((resumes) => resumes[0]);
  }

  Future<List<Map<String, dynamic>>> _fetchResumeData() async {
    final response = await http.get(Uri.parse(
        'http://192.168.8.106:4000/api/cv/getResumesByCvId/$resumeId'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      final List<Map<String, dynamic>> resumes =
      responseData.cast<Map<String, dynamic>>();
      return resumes;
    } else {
      throw Exception('Failed to load resume data');
    }
  }

  @override
  PreferredSizeWidget? buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return

             AppBar(
          title: Text('Resume Preview', style: TextStyle(color: Colors.black),),
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
      body: FutureBuilder(
        future: resumeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to fetch resume data'));
          } else {
            final resumeData = snapshot.data as Map<String, dynamic>;
            return _buildResumePreview(resumeData);
          }
        },
      ),
    );
  }

  Widget _buildResumePreview(Map<String, dynamic> resumeData) {
    Widget resumePreview;

    switch (resumeData['template']) {
      case 'template1':
        resumePreview = Template1(resumeData: resumeData);

        break;
      case 'template2':
        resumePreview = Template2(resumeData: resumeData);

        break;
      case 'template3':
        resumePreview = Template3(resumeData: resumeData);
        break;
      default:
        resumePreview =
            Text('Unknown template: ${resumeData['template']}');
        break;
    }

    return resumePreview;
  }
}




class Template2 extends StatelessWidget {
  final Map<String, dynamic> resumeData;
  final ScreenshotController screenshotController = ScreenshotController();
  Template2({required this.resumeData});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> saveAsPDF(BuildContext context, GlobalKey previewContainer) async {
    try{
      RenderRepaintBoundary boundary =
      previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List bytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              color: PdfColors.cyan300,
              child: pw.Stack(
                children: [
                  pw.Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: pw.Center(
                      child: pw.Image(imageProvider),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/resume.pdf';

      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      print('PDF saved to: $path');
      showSnackBar(context, 'PDF Downloaded to internal storage');
    } catch (e) {
      print('Failed to save PDF: $e');
      showSnackBar(context, 'Download failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey previewContainer = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            color: Colors.black,
            onPressed: () => saveAsPDF(context, previewContainer),
          ),

        ],
      ),
      body: SizedBox.expand(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16), // Adjust the margin values
            decoration: BoxDecoration(
              color: Colors.cyan[300],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: RepaintBoundary(
                      key: previewContainer,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  color: Colors.cyan[300],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: Colors.cyan[300],
                                        width: double.infinity,
                                        child: Text(
                                          '${resumeData['Name']}',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Divider(),
                                      Icon(Icons.email_rounded),
                                      SizedBox(height: 8),
                                      Container(
                                        child: Text(
                                          '${resumeData['email']}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(Icons.phone),
                                      SizedBox(height: 8),
                                      Container(
                                        child: Text(
                                          '${resumeData['phone']}',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(Icons.home),
                                      SizedBox(height: 8),
                                      Container(
                                        child: Text(
                                          '${resumeData['address']}',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Profile',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        color: Colors.cyan[300],
                                        child: Text(
                                          '${resumeData['profile'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Skills',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['skills'].split(", ").join(", ").replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Education',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['education'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Employment History',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['EmploymentHistory'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Experiences',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['references'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






class Template1 extends StatelessWidget {

  final Map<String, dynamic> resumeData;

  Template1({required this.resumeData});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> saveAsPDF(BuildContext context, GlobalKey previewContainer) async {
    try{
    RenderRepaintBoundary boundary =
    previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = byteData!.buffer.asUint8List();

    final pdf = pw.Document();
    final imageProvider = pw.MemoryImage(bytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(imageProvider),
          );
        },
      ),
    );

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/resume.pdf';

    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    print('PDF saved to: $path');
    showSnackBar(context, 'PDF Downloaded to internal storage');
  } catch (e) {
  print('Failed to save PDF: $e');
  showSnackBar(context, 'Download failed');
  }
  }



  @override
  Widget build(BuildContext context) {
    GlobalKey previewContainer = GlobalKey();

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        margin: EdgeInsets.all(16),
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: previewContainer,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Details', // Added 'Contact Details' text
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Divider(),
                              Text(
                                'Name',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['Name']}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),

                              Text(
                                'Email',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(0,8,8,8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['email']}',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),

                              Text(
                                'Phone',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['phone']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                'Address',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['address']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Divider(),
                              Text(
                                'Profile',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['profile'].replaceAll(',', '\n')}',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                'Education',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['education'].replaceAll(',', '\n')}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Divider(),
                              Text(
                                'Employment History',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['EmploymentHistory'].replaceAll(',', '\n')}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Divider(),
                              Text(
                                'Skills',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['skills'].split(", ").join(", ").replaceAll(',', '\n')}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Divider(),
                              Text(
                                'Experiences',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: Text(
                                  '${resumeData['references'].replaceAll(',', '\n')}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                icon: Icon(Icons.download),
                label: Text('Download PDF'),
                onPressed: () => saveAsPDF(context, previewContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class Template3 extends StatelessWidget {

  final Map<String, dynamic> resumeData;
  final ScreenshotController screenshotController = ScreenshotController();
  Template3({required this.resumeData});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> saveAsPDF(BuildContext context, GlobalKey previewContainer) async {
    try {
      RenderRepaintBoundary boundary =
      previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List bytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              color: PdfColors.grey400,
              child: pw.Stack(
                children: [
                  pw.Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: pw.Center(
                      child: pw.Image(imageProvider),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );


      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/resume.pdf';

      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      print('PDF saved to: $path');
      showSnackBar(context, 'PDF Downloaded to internal storage');
    } catch (e) {
      print('Failed to save PDF: $e');
      showSnackBar(context, 'Download failed');
    }

  }


  @override
  Widget build(BuildContext context) {
    GlobalKey previewContainer = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            color: Colors.black,
            onPressed: () => saveAsPDF(context, previewContainer),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16), // Adjust the margin values
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: RepaintBoundary(
                      key: previewContainer,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  color: Colors.grey[400],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: Colors.grey[400],
                                        width: double.infinity,
                                        child: Text(
                                          '${resumeData['Name']}',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Divider(),
                                      Icon(Icons.email_rounded , size: 17,),
                                      SizedBox(height: 8),
                                      Container(
                                        child: Text(
                                          '${resumeData['email']}',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Icon(Icons.phone , size: 17,),
                                      SizedBox(height: 8),
                                      Container(
                                        child: Text(
                                          '${resumeData['phone']}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(Icons.home , size: 17,),
                                      SizedBox(height: 8),
                                      Container(
                                        child: Text(
                                          '${resumeData['address']}',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Profile',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        color: Colors.grey[400],
                                        child: Text(
                                          '${resumeData['profile'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Skills',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['skills'].split(", ").join(", ").replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Education',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['education'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Employment History',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['EmploymentHistory'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Experiences',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: Text(
                                          '${resumeData['references'].replaceAll(',', '\n')}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }




}