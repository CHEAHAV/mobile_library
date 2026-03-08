class Category{
    final int id;
    final String category;

    Category({
        required this.id,
        required this.category,
    });

    factory Category.fromson(Map<String, dynamic> json){
        return Category(
            id : json['id'],
            category : json['category_name'],
        );
    }
}