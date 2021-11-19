import 'dart:typed_data';

import 'package:blake_hash/blake_hash.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

void main() {
  group('blake test', () {
    List<Map<String, String>> vectors = <Map<String, String>>[
      {
        'input': '00',
        'blake256':
            '0ce8d4ef4dd7cd8d62dfded9d4edb0a774ae6a41929a74da23109e8f11139c87',
        'blake512':
            '97961587f6d970faba6d2478045de6d1fabd09b61ae50932054d52bc29d31be4ff9102b9f69e2bbdb83be13d4b9c06091e5fa0b48bd081b634058be0ec49beb3',
      },
      {
        'input':
            '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
        'blake256':
            'd419bad32d504fb7d44d460c42c5593fe544fa4c135dec31e21bd9abdcc22d41',
        'blake512':
            '2f31e729e269c7f22cac8b71cb80a504afe38350498e0d178afb38cc356dfdaf55d1e7d723c8ff686df0710c43d9abef9f0f61b91ab3b49f72b96f899159a735',
      }
    ];

    vectors.forEach((vector) {
      test('blake256 vector#${vectors.indexOf(vector)}', () {
        expect(
            vector['blake256'],
            hex.encode(Blake256()
                .update(Uint8List.fromList(hex.decode(vector['input']!)))
                .digest()));
      });

      test('blake512 vector#${vectors.indexOf(vector)}', () {
        expect(
            vector['blake512'],
            hex.encode(Blake512()
                .update(Uint8List.fromList(hex.decode(vector['input']!)))
                .digest()));
      });
    });
  });
}
