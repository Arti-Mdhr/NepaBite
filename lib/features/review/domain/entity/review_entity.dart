class ReviewEntity {
  final String id;
  final String userName;
  final String comment;
  final int rating;
  final DateTime createdAt;
  final bool isOwner;

  ReviewEntity({
    required this.id,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
    required this.isOwner,
  });
}