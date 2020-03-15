Implementation of Blake encryption algorithm

## Usage

A simple usage example:

```dart
import 'dart:typed_data';

import 'package:blake_hash/blake_hash.dart';

void main() {
  var source = Uint8List.fromList([14, 251, 24, 220, 202, 235, 97, 232, 85, 229, 109, 188, 53, 146, 43, 36, 246, 238, 110, 55, 202, 163]);
  var hash = Blake256().update(source).digest();
  print(hash);
  /// => [102, 119, 97, 10, 202, 38, 121, 69, 113, 107, 204, 30, 2, 56, 132, 219, 223, 178, 104, 33, 38, 181, 219, 126, 87, 74, 200, 152, 115, 14, 108, 138]
  print(Blake256().update(hash).digest());
  /// => [160, 123, 169, 35, 32, 106, 124, 57, 39, 1, 52, 241, 107, 182, 255, 52, 253, 188, 54, 150, 214, 169, 56, 120, 60, 214, 85, 151, 232, 87, 222, 19]
}

```


## LICENSE

This library is free and open-source software released under the MIT license.
