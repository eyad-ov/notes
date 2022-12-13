import 'package:encrypt/encrypt.dart';

class AESEncryption {

//find a more secure way of generating keys/iv randomly for every user
// and find a way to store theses keys in ordere to retrieve them after
// 1.approach: server
// 2.approach: local with package flutter_secure_storage 

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
