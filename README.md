Implementation of Blake encryption algorithm

## Install
```yaml
dependencies:
  blake_hash: ^1.0.2
```

## Usage

A simple usage example:

```dart
import 'dart:typed_data';
import 'package:blake_hash/blake_hash.dart';

void main() {
  Uint8List source = Uint8List.fromList([
    14, 251, 24, 220, 202, 235, 97, 232, //
    85, 229, 109, 188, 53, 146, 43, 36,
    246, 238, 110, 55, 202, 163
  ]);
  Blake blake = Blake256();
  source = blake.update(source).digest();
  print(source);

  /// => [102, 119, 97, 10, 202, 38, 121, 69, 113, 107, 204, 30, 2, 56, 132, 219, 223, 178, 104, 33, 38, 181, 219, 126, 87, 74, 200, 152, 115, 14, 108, 138]

  source = blake.reset().update(source).digest();
  print(source);

  /// => [160, 123, 169, 35, 32, 106, 124, 57, 39, 1, 52, 241, 107, 182, 255, 52, 253, 188, 54, 150, 214, 169, 56, 120, 60, 214, 85, 151, 232, 87, 222, 19]

  blake = Blake512();
  source = blake.update(source).digest();
  print(source);

  /// => [117, 52, 187, 72, 187, 76, 107, 178, 112, 89, 59, 37, 165, 71, 131, 97, 175, 233, 9, 153, 195, 129, 194, 195, 21, 219, 210, 135, 27, 138, 195, 195, 88, 222, 226, 177, 248, 177, 249, 104, 10, 65, 64, 133, 3, 39, 178, 163, 188, 199, 27, 131, 233, 51, 173, 224, 155, 187, 234, 240, 8, 213, 69, 248]

  source = blake.reset().update(source).digest();
  print(source);

  /// => [160, 201, 200, 166, 213, 62, 61, 9, 179, 14, 57, 12, 52, 136, 190, 72, 163, 161, 65, 80, 246, 114, 151, 80, 159, 29, 171, 230, 179, 36, 37, 7, 71, 182, 118, 226, 144, 41, 123, 79, 123, 157, 83, 71, 226, 182, 246, 151, 58, 106, 56, 171, 152, 43, 43, 131, 197, 189, 228, 224, 198, 11, 176, 206]
}
```


## LICENSE

This library is free and open-source software released under the MIT license.
