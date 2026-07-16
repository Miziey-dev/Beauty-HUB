class Category {
  final String slug;
  final String label;

  const Category({required this.slug, required this.label});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        slug: json['slug'] as String,
        label: json['label'] as String,
      );
}
