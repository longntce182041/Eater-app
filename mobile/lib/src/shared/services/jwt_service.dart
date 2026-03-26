import 'dart:convert';

class JwtService {
  int? getExpiryEpochSeconds(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      return payload['exp'] as int?;
    } catch (_) {
      return null;
    }
  }

  bool isExpired(String token) {
    final expiry = getExpiryEpochSeconds(token);
    if (expiry == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiry;
  }

  bool willExpireWithin(String token, Duration leeway) {
    final expiry = getExpiryEpochSeconds(token);
    if (expiry == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (expiry - now) <= leeway.inSeconds;
  }
}
