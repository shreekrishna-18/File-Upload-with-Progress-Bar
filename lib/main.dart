import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FileUploadPage(),
    );
  }
}

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  double progress = 0.0;
  Dio dio = Dio();
  String fileName = '';

  // Method to pick a file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? filePath = result.files.single.path;
      fileName = result.files.single.name;
      if (filePath != null) {
        uploadFile(filePath);
      }
    }
  }

  // Method to upload file with progress
  Future<void> uploadFile(String filePath) async {
    String uploadUrl = 'https://your-server-url.com/upload';  // Replace with your server URL

    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    try {
      await dio.post(uploadUrl, data: formData, onSendProgress: (sent, total) {
        setState(() {
          progress = sent / total;
        });
      });

      // Display success dialog after upload
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Upload Complete'),
          content: Text('File uploaded successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Upload failed: $e');
      // Display failure dialog if upload fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Upload Failed'),
          content: Text('Something went wrong, please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Upload with Progress Bar')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: pickFile,
                child: Text('Pick and Upload File'),
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
              SizedBox(height: 20),
              Text('${(progress * 100).toStringAsFixed(0)}% uploaded'),
            ],
          ),
        ),
      ),
    );
  }
}
