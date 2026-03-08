import 'package:flutter/material.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/pdf_viewer_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = ApiService().fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Books Library')),
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Book book = snapshot.data![index];
                return ListTile(
                  leading: book.coverImage.isNotEmpty
                      ? Image.network(
                          '${ApiService.baseUrl}/covers/${book.coverImage}',
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book),
                        )
                      : const Icon(Icons.book),
                  title: Text(book.title),
                  subtitle: Text(book.authorName ?? 'Unknown Author'),
                  trailing: book.rating != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(book.rating!.toStringAsFixed(1)),
                          ],
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          book: book,
                          downloadUrl: ApiService().getDownloadUrl(book.id),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('No books found.'));
        },
      ),
    );
  }
}