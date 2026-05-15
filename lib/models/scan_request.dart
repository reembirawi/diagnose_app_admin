class ScanRequest {
  final String imageUrl;
  final DateTime createdAt;

  ScanRequest({
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ScanRequest.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    final createdAt = raw is String
        ? DateTime.parse(raw)
        : (raw?.toDate() ?? DateTime.now());

    return ScanRequest(
      imageUrl: map['imageUrl'] ?? '',
      createdAt: createdAt,
    );
  }
}