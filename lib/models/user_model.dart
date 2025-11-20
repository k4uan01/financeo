class UserModel {
  final String id;
  final DateTime createdAt;
  final String? fullName;
  final String? profilePhoto;

  UserModel({
    required this.id,
    required this.createdAt,
    this.fullName,
    this.profilePhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      fullName: json['full_name'] as String?,
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'full_name': fullName,
      'profile_photo': profilePhoto,
    };
  }
}

class GetUserResponse {
  final bool status;
  final String message;
  final UserModel? user;

  GetUserResponse({
    required this.status,
    required this.message,
    this.user,
  });

  factory GetUserResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>?;
    UserModel? user;
    
    if (data != null && data.isNotEmpty) {
      user = UserModel.fromJson(data[0] as Map<String, dynamic>);
    }

    return GetUserResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      user: user,
    );
  }
}

