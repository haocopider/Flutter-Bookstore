class LoginResponse {
  final String token;
  final UserInfo user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: UserInfo.fromJson(json['user']),
    );
  }
}

class UserInfo {
  final int id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String address;
  final String phoneNumber;
  final int currentPoints;
  final int totalPoints;
  final int rank;

  UserInfo({required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.address,
    required this.phoneNumber,
    required this.currentPoints,
    required this.totalPoints,
    required this.rank });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      currentPoints: json['currentPoints'],
      totalPoints: json['totalPoints'],
      rank: json['rank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'currentPoints': currentPoints,
      'totalPoints': totalPoints,
      'rank': rank,
    };
  }
}