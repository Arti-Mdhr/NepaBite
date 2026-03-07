import '../../domain/entity/review_entity.dart';

class ReviewApiModel {
  final String userName;
  final String comment;
  final int rating;

  ReviewApiModel({
    required this.userName,
    required this.comment,
    required this.rating,
  });

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    return ReviewApiModel(
      userName: json["userName"] ?? "User",
      comment: json["comment"] ?? "",
      rating: json["rating"] ?? 0,
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      userName: userName,
      comment: comment,
      rating: rating,
    );
  }
}