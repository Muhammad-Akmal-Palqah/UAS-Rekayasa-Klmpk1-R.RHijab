class Comment {
  final int id;
  final String author;
  final String message;
  final int rating;
  final String? imageUrl;
  final String? profileImageUrl;
  final String createdAt;

  Comment({
    required this.id,
    required this.author,
    required this.message,
    required this.rating,
    this.imageUrl,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'];
    final userData = userMap is Map
        ? Map<String, dynamic>.from(userMap.cast<String, dynamic>())
        : null;

    String? extractProfileImageUrl() {
      final candidates = [
        json['profile_image_url']?.toString(),
        json['profile_photo_url']?.toString(),
        json['user_photo_url']?.toString(),
        json['photo_url']?.toString(),
        json['avatar_url']?.toString(),
        json['avatar']?.toString(),
        json['user_photo']?.toString(),
        json['profile_photo']?.toString(),
        userData?['profile_image_url']?.toString(),
        userData?['profile_photo_url']?.toString(),
        userData?['photo_url']?.toString(),
        userData?['avatar_url']?.toString(),
        userData?['avatar']?.toString(),
        userData?['photo']?.toString(),
      ];

      for (final candidate in candidates) {
        if (candidate != null && candidate.isNotEmpty) {
          return candidate;
        }
      }
      return null;
    }

    return Comment(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      author:
          json['user_name']?.toString() ??
          json['author']?.toString() ??
          'Pengguna',
      message:
          json['komentar']?.toString() ?? json['message']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      imageUrl: json['image_url']?.toString(),
      profileImageUrl: extractProfileImageUrl(),
      createdAt:
          json['created_at']?.toString() ?? json['date']?.toString() ?? '',
    );
  }

  String get fullImageUrl {
    return imageUrl ?? '';
  }

  String get fullProfileImageUrl {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      return '';
    }

    final url = profileImageUrl!.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/')) {
      return 'http://127.0.0.1:8000$url';
    }

    return 'http://127.0.0.1:8000/$url';
  }
}
