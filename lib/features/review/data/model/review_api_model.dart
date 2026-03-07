import '../../domain/entity/review_entity.dart';

class ReviewApiModel {
  final String id;
  final String userName;
  final String comment;
  final int rating;
  final DateTime createdAt;
  final bool isOwner;

  ReviewApiModel({
    required this.id,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
    required this.isOwner,
  });

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    return ReviewApiModel(
      id: json["_id"],
      userName: json["userName"] ?? "User",
      comment: json["comment"],
      rating: json["rating"],
      createdAt: DateTime.parse(json["createdAt"]),
      isOwner: json["isOwner"] ?? false,
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      userName: userName,
      comment: comment,
      rating: rating,
      createdAt: createdAt,
      isOwner: isOwner,
    );
  }
}