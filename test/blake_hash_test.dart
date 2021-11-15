import 'dart:typed_data';

import 'package:blake_hash/blake_hash.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

void main() {
  group('blake test', () {
    var vectors = <Map<String, String>>[
      {
        'input': '00',
        'blake256':
            '0ce8d4ef4dd7cd8d62dfded9d4edb0a774ae6a41929a74da23109e8f11139c87',
      },
      {
        'input':
            '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
        'blake256':
            'd419bad32d504fb7d44d460c42c5593fe544fa4c135dec31e21bd9abdcc22d41'
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
    });
  });
}
