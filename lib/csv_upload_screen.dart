import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadCsvScreen extends StatelessWidget {
  Future<void> uploadCsvFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null) return;

    final file = result.files.single.bytes;
    final rows = const Utf8Decoder().convert(file!).split('\n');
    final headers = rows[0].split(',');

    final List<Map<String, dynamic>> questions = [];
    for (var i = 1; i < rows.length; i++) {
      final values = rows[i].split(',');
      final question = Map.fromIterables(headers, values);
      questions.add(question);
    }

    for (final question in questions) {
      await FirebaseFirestore.instance.collection('questions').add(question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload CSV")),
      body: Center(
        child: ElevatedButton(onPressed: uploadCsvFile, child: Text("Select CSV File")),
      ),
    );
  }
}
