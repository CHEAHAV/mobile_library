class Book {
  final String id;
  final String title;
  final String? description;
  final String? authorName;
  final double? rating;
  final String? language;
  final int? page;
  final String coverName;
  final String fileName;
  final String? categoryId;

  Book({
    required this.id,
    required this.title,
    this.description,
    this.authorName,
    this.rating,
    this.language,
    this.page,
    required this.coverName,
    required this.fileName,
    required this.categoryId,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id:          json['id'] as String,
      title:       json['title'] as String? ?? '',
      description: json['description'] as String?,
      authorName:  json['author_name'] as String?,
      rating:      json['rating'] != null ? double.parse(json['rating'].toString()) : null,
      language:    json['language'] as String?,
      page:        (json['page'] as num?)?.toInt(),
      coverName:   json['cover_name'] as String? ?? '',
      fileName:    json['file_name'] as String? ?? '',
      categoryId:  json['category_id'] as String,
    );
  }
}