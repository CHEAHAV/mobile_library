import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/components/circle_button.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/services/api_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final Book book;
  final String downloadUrl;

  const PdfViewerScreen({
    super.key,
    required this.book,
    required this.downloadUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPdfBytes();
  }

  Future<void> _fetchPdfBytes() async {
    try {
      final response = await http.get(
        Uri.parse(widget.downloadUrl),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        leading: CircleButton(
          dark: false,
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 119, 82, 3),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.book.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFB8860B)),
                  SizedBox(height: 16),
                  Text(
                    'Loading PDF...',
                    style: TextStyle(color: Color(0xFFB8860B)),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF3E2A00)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _fetchPdfBytes();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SfPdfViewer.memory(_pdfBytes!),
    );
  }
}
