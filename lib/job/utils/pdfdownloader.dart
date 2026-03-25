import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';

class PdfDownloader {

  Future<void> openInvoice(String url, BuildContext context) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Downloading PDF...'),
            ],
          ),
        );
      },
    );

    try {
      // Get app-specific directory (NO PERMISSION NEEDED!)
      final directory = await getApplicationDocumentsDirectory();

      // Generate file name
      final fileName = 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';

      // Download the file
      final response = await http.get(Uri.parse(url));

      // Close progress dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // Write file to disk
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Automatically open the PDF
        final result = await OpenFilex.open(filePath);
        print('Open result: ${result.message}');

      } else {
        _showErrorDialog(context, 'Failed to download PDF. Status: ${response.statusCode}');
      }

    } catch (e) {
      // Close progress dialog if still open
      Navigator.of(context, rootNavigator: true).pop();

      _showErrorDialog(context, 'Error downloading PDF: $e');
      print('Error: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
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