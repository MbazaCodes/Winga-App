import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  /// SHA-256 hash — much safer than base64
  /// In production: use bcrypt via a server-side Edge Function
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String plain, String hashed) {
    return hashPassword(plain) == hashed;
  }
}
