import 'package:encrypt/encrypt.dart';

/// responsible for encryption/decryption of notes in database
class AESEncryption {

  static final key = Key.fromUtf8("A%D*G-JaNdRgUkXp");
  static final iv = IV.fromUtf8("123456789abcdefg");
  
  static String encrypt(String plainText) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decrypt(String cipherText) {
    final encrypted = Encrypted.from64(cipherText);
    final encrypter = Encrypter(AES(key));
    final plainText = encrypter.decrypt(encrypted, iv: iv);
    return plainText;
  }
}
