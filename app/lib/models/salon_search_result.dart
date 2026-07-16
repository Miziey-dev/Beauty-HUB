class SalonSearchResult {
  final String id;
  final String name;

  const SalonSearchResult({required this.id, required this.name});

  factory SalonSearchResult.fromJson(Map<String, dynamic> json) => SalonSearchResult(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}
