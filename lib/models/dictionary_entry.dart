class DictionaryEntry {
  final int id;
  final String word;
  final String description;
  final String? videoUrl;
  final String? imageUrl;
  final String category;
  final String submittedBy;
  final String status;
  final DateTime? createdAt;

  DictionaryEntry({
    required this.id,
    required this.word,
    required this.description,
    this.videoUrl,
    this.imageUrl,
    required this.category,
    required this.submittedBy,
    this.status = 'pending',
    this.createdAt,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      id: json['id'],
      word: json['word'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
      category: json['category'] ?? 'Lainnya',
      submittedBy: json['submittedBy'] ?? 'Anonim',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'description': description,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'category': category,
      'submittedBy': submittedBy,
      'status': status,
    };
  }
}