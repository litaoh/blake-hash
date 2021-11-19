part of blake_hash;

Uint8List _zo = Uint8List.fromList([0x01]);
Uint8List _oo = Uint8List.fromList([0x81]);

abstract class Blake {
  static final List<Uint8List> sigma = [
    Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    Uint8List.fromList([14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3]),
    Uint8List.fromList([11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4]),
    Uint8List.fromList([7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8]),
    Uint8List.fromList([9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13]),
    Uint8List.fromList([2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9]),
    Uint8List.fromList([12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11]),
    Uint8List.fromList([13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10]),
    Uint8List.fromList([6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5]),
    Uint8List.fromList([10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0]),
    Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    Uint8List.fromList([14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3]),
    Uint8List.fromList([11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4]),
    Uint8List.fromList([7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8]),
    Uint8List.fromList([9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13]),
    Uint8List.fromList([2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9])
  ];

  static final List<int> u256 = [
    0x243f6a88, 0x85a308d3, 0x13198a2e, 0x03707344, //
    0xa4093822, 0x299f31d0, 0x082efa98, 0xec4e6c89,
    0x452821e6, 0x38d01377, 0xbe5466cf, 0x34e90c6c,
    0xc0ac29b7, 0xc97c50dd, 0x3f84d5b5, 0xb5470917
  ];

  static final List<int> u512 = [
    ...u256,
    0x9216d5d9, 0x8979fb1b, 0xd1310ba6, 0x98dfb5ac, //
    0x2ffd72db, 0xd01adfb7, 0xb8e1afed, 0x6a267e96,
    0xba7c9045, 0xf12c7f99, 0x24a19947, 0xb3916cf7,
    0x0801f2e2, 0x858efc16, 0x636920d8, 0x71574e69
  ];

  static final Uint8List padding =
      Uint8List.fromList([0x80, ...List.filled(127, 0)]);

  late ByteData _block;
  late int _blockOffset;
  late List<int> _h;
  late List<int> _length;

  void _length_carry(List<int> data) {
    for (int j = 0; j < data.length; ++j) {
      if (data[j] < 0x0100000000) {
        break;
      }
      data[j] -= 0x0100000000;
      data[j + 1] += 1;
    }
  }

  Blake reset();

  void _compress();

  Uint8List digest();

  Blake update(Uint8List data) {
    int offset = 0;

    while (_blockOffset + data.length - offset >= _block.lengthInBytes) {
      for (int i = _blockOffset; i < _block.lengthInBytes;) {
        _block.setUint8(i++, data[offset++]);
      }

      _length[0] += _block.lengthInBytes << 3;
      _length_carry(_length);

      _compress();
      _blockOffset = 0;
    }

    while (offset < data.length) {
      _block.setUint8(_blockOffset++, data[offset++]);
    }
    return this;
  }
}
