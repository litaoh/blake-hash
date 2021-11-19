part of blake_hash;

class Blake256 extends Blake {
  late List<int> _s;
  late bool _nullT;

  Blake256() : super() {
    reset();
  }

  @override
  Blake256 reset() {
    _h = [
      0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    ];

    _s = List<int>.filled(4, 0);

    _block = ByteData(64);

    _blockOffset = 0;
    _length = List<int>.filled(2, 0);

    _nullT = false;

    return this;
  }

  int _rot(int x, int n) {
    return ((x << (32 - n)) | (x >> n).toUnsigned(32)).toUnsigned(32);
  }

  void _g(List<int> v, List<int> m, int i, int a, int b, int c, int d, int e) {
    List<Uint8List> sigma = Blake.sigma;
    List<int> u256 = Blake.u256;
    v[a] = (v[a] +
            ((m[sigma[i][e]] ^ u256[sigma[i][e + 1]]).toUnsigned(32)) +
            v[b])
        .toUnsigned(32);
    v[d] = _rot(v[d] ^ v[a], 16);
    v[c] = (v[c] + v[d]).toUnsigned(32);
    v[b] = _rot(v[b] ^ v[c], 12);
    v[a] = (v[a] +
            ((m[sigma[i][e + 1]] ^ u256[sigma[i][e]]).toUnsigned(32)) +
            v[b])
        .toUnsigned(32);
    v[d] = _rot(v[d] ^ v[a], 8);
    v[c] = (v[c] + v[d]).toUnsigned(32);
    v[b] = _rot(v[b] ^ v[c], 7);
  }

  @override
  void _compress() {
    List<int> u256 = Blake.u256;
    List<int> v = List.filled(16, 0);
    List<int> m = List.filled(16, 0);

    for (int i = 0; i < 16; ++i) {
      m[i] = _block.getUint32(i * 4);
    }

    for (int i = 0; i < 8; ++i) {
      v[i] = _h[i];
    }
    for (int i = 8; i < 12; ++i) {
      v[i] = (_s[i - 8] ^ u256[i - 8]);
    }
    for (int i = 12; i < 16; ++i) {
      v[i] = u256[i - 8];
    }
    if (!_nullT) {
      v[12] ^= _length[0];
      v[13] ^= _length[0];
      v[14] ^= _length[1];
      v[15] ^= _length[1];
    }

    for (int i = 0; i < 14; ++i) {
      /* column step */
      _g(v, m, i, 0, 4, 8, 12, 0);
      _g(v, m, i, 1, 5, 9, 13, 2);
      _g(v, m, i, 2, 6, 10, 14, 4);
      _g(v, m, i, 3, 7, 11, 15, 6);
      /* diagonal step */
      _g(v, m, i, 0, 5, 10, 15, 8);
      _g(v, m, i, 1, 6, 11, 12, 10);
      _g(v, m, i, 2, 7, 8, 13, 12);
      _g(v, m, i, 3, 4, 9, 14, 14);
    }

    for (int i = 0; i < 16; ++i) {
      _h[i % 8] ^= v[i];
    }
    for (int i = 0; i < 8; ++i) {
      _h[i] ^= _s[i % 4];
    }
  }

  void _padding() {
    int lo = _length[0] + _blockOffset * 8;
    int hi = _length[1];
    if (lo >= 0x0100000000) {
      lo -= 0x0100000000;
      hi += 1;
    }

    ByteData msgLen = ByteData(8);

    msgLen.setUint32(0, hi);

    msgLen.setUint32(4, lo);

    if (_blockOffset == 55) {
      _length[0] -= 8;
      update(_oo);
    } else {
      if (_blockOffset < 55) {
        if (_blockOffset == 0) _nullT = true;
        _length[0] -= (55 - _blockOffset) << 3;
        update(Blake.padding.sublist(0, 55 - _blockOffset));
      } else {
        _length[0] -= (64 - _blockOffset) << 3;
        update(Blake.padding.sublist(0, 64 - _blockOffset));
        _length[0] -= 55 * 8;
        update(Blake.padding.sublist(1, 1 + 55));
        _nullT = true;
      }

      update(_zo);
      _length[0] -= 8;
    }

    _length[0] -= 64;
    update(msgLen.buffer.asUint8List());
  }

  @override
  Uint8List digest() {
    _padding();
    ByteData buffer = ByteData(32);

    for (int i = 0; i < 8; ++i) {
      buffer.setUint32(i << 2, _h[i]);
    }
    return buffer.buffer.asUint8List();
  }
}
