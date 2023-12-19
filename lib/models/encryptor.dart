import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

final ENCRYPTION_KEY = 'K4EdLm4Qob5644xDumFG2x6RF-';
final ENCRYPTION_IV = 'ozaieUJ/MOe7MD4gFoirdg==';

const _UNIQ_KEY = 'RSGILL';

class Encryptor {

  static String encryptAES(String plainText, {
    String uniqueKey = _UNIQ_KEY
  }) {
    final key = _getEncryptionKey(uniqueKey: uniqueKey);
    final iv = _getEncryptionIV();

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  static String decryptAES(String encryptedText, {
    String uniqueKey = _UNIQ_KEY
  }) {
    final key = _getEncryptionKey(uniqueKey: uniqueKey);
    final iv = _getEncryptionIV();

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);

    return decrypted;
  }

  static Key _getEncryptionKey({
    String uniqueKey = _UNIQ_KEY
  }) {
    return Key(Uint8List.fromList(utf8.encode(ENCRYPTION_KEY + uniqueKey)));
  }

  static IV _getEncryptionIV() {
    return IV.fromBase64(ENCRYPTION_IV);
  }

}