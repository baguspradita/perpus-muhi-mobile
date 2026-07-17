import 'package:equatable/equatable.dart';

class AuthTokenEntity extends Equatable {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  const AuthTokenEntity({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokenEntity.fromJson(Map<String, dynamic> json) {
    return AuthTokenEntity(
      accessToken: json['token'] as String? ?? json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: json['expires_in'] as int? ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }

  @override
  List<Object?> get props => [accessToken, tokenType, expiresIn];
}