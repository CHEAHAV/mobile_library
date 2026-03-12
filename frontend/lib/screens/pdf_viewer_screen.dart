import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:frontend/models/book.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
  String? _localPath;
  bool _isLoading = true;
  String? _error;

  // PDF controller & state
  int? pages;
  int currentPage = 0;
  bool isReady = false;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  @override
  void initState() {
    super.initState();
    // hide status bar + nav bar immediately
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _downloadAndSavePdf();
  }

  @override
  void dispose() {
    // restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final response = await http.get(Uri.parse(widget.downloadUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = Uri.decodeComponent(
          widget.downloadUrl.split('/').last,
        );
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to download PDF (${response.statusCode})';
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
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Loading PDF...', style: TextStyle(color: Colors.white)),
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
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _downloadAndSavePdf();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // PDF fills entire screen
                Positioned.fill(
                  child: PDFView(
                    filePath: _localPath!,
                    enableSwipe: true,
                    swipeHorizontal: false, // vertical scroll
                    autoSpacing: false,
                    pageFling: true,
                    pageSnap: false,
                    fitPolicy: FitPolicy.BOTH, // ← fits page to full screen
                    backgroundColor: Colors.grey.shade900,
                    onRender: (totalPages) {
                      setState(() {
                        pages = totalPages;
                        isReady = true;
                      });
                    },
                    onError: (error) {
                      setState(() {
                        _error = error.toString();
                      });
                    },
                    onPageError: (page, error) {
                      debugPrint('Page $page error: $error');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _controller.complete(pdfViewController);
                    },
                    onPageChanged: (int? page, int? total) {
                      setState(() {
                        currentPage = page ?? 0;
                      });
                    },
                  ),
                ),

                // back button overlay (top-left)
                Positioned(
                  top: 16,
                  left: 8,
                  child: SafeArea(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),

                // page indicator (bottom-center)
                if (isReady && pages != null)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentPage + 1} / $pages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
