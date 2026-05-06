class Review {
  final int userId;
  final int bookId;
  final int ratingValue;
  final String? comment;
  final String? reviewImg;
  final String? userName;

  Review({
    required this.userId,
    required this.bookId,
    required this.ratingValue,
    this.comment,
    this.reviewImg,
    this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] as int? ?? 0,
      bookId: json['bookId'] as int? ?? 0,
      ratingValue: json['ratingValue'] as int? ?? 5,
      comment: json['comment'] as String?,
      reviewImg: json['reviewImg'] as String?,
      userName: json['userName'] as String? ?? 'Khách hàng',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bookId': bookId,
      'ratingValue': ratingValue,
      'comment': comment,
      'reviewImg': reviewImg,
    };
  }
}