import '../../domain/entity/token.dart';

class TokenDTO {
  final String token;

  TokenDTO({required this.token});

  factory TokenDTO.fromJson(String token) {
    return TokenDTO(token: token);
  }

  Token toEntity() {
    return Token(
      accessToken: token,
    );
  }
}
