part of blake_hash;

class Blake512 extends Blake {
  late List<int> _s;
  late bool _nullT;

  Blake512() : super() {
    reset();
  }

  @override
  Blake512 reset() {
    _h = [
      0x6a09e667, 0xf3bcc908, 0xbb67ae85, 0x84caa73b, //
      0x3c6ef372, 0xfe94f82b, 0xa54ff53a, 0x5f1d36f1,
      0x510e527f, 0xade682d1, 0x9b05688c, 0x2b3e6c1f,
      0x1f83d9ab, 0xfb41bd6b, 0x5be0cd19, 0x137e2179
    ];

    _s = List<int>.filled(8, 0);

    _block = ByteData(128);

    _blockOffset = 0;
    _length = List<int>.filled(4, 0);

    _nullT = false;

    return this;
  }

  void _rot(List<int> v, int i, int j, int n) {
    int hi = v[i * 2] ^ v[j * 2];
    int lo = v[i * 2 + 1] ^ v[j * 2 + 1];

    if (n >= 32) {
      lo = lo ^ hi;
      hi = lo ^ hi;
      lo = lo ^ hi;
      n -= 32;
    }

    if (n == 0) {
      v[i * 2] = hi.toUnsigned(32);
      v[i * 2 + 1] = lo.toUnsigned(32);
    } else {
      v[i * 2] = ((hi >> n).toUnsigned(32) | (lo << (32 - n))).toUnsigned(32);
      v[i * 2 + 1] =
          ((lo >> n).toUnsigned(32) | (hi << (32 - n))).toUnsigned(32);
    }
  }

  void _g(List<int> v, List<int> m, int i, int a, int b, int c, int d, int e) {
    List<Uint8List> sigma = Blake.sigma;
    List<int> u512 = Blake.u512;
    int lo = v[a * 2 + 1] +
        ((m[sigma[i][e] * 2 + 1] ^ u512[sigma[i][e + 1] * 2 + 1])
            .toUnsigned(32)) +
        v[b * 2 + 1];
    v[a * 2] = (v[a * 2] +
            ((m[sigma[i][e] * 2] ^ u512[sigma[i][e + 1] * 2]).toUnsigned(32)) +
            v[b * 2] +
            (lo ~/ 0x0100000000))
        .toUnsigned(32);
    v[a * 2 + 1] = lo.toUnsigned(32);
    _rot(v, d, a, 32);
    lo = v[c * 2 + 1] + v[d * 2 + 1];
    v[c * 2] = (v[c * 2] + v[d * 2] + (lo ~/ 0x0100000000)).toUnsigned(32);
    v[c * 2 + 1] = lo.toUnsigned(32);
    _rot(v, b, c, 25);
    lo = v[a * 2 + 1] +
        ((m[sigma[i][e + 1] * 2 + 1] ^ u512[sigma[i][e] * 2 + 1])
            .toUnsigned(32)) +
        v[b * 2 + 1];
    v[a * 2] = (v[a * 2] +
            ((m[sigma[i][e + 1] * 2] ^ u512[sigma[i][e] * 2]).toUnsigned(32)) +
            v[b * 2] +
            (lo ~/ 0x0100000000))
        .toUnsigned(32);
    v[a * 2 + 1] = lo.toUnsigned(32);
    _rot(v, d, a, 16);
    lo = v[c * 2 + 1] + v[d * 2 + 1];
    v[c * 2] = (v[c * 2] + v[d * 2] + (lo ~/ 0x0100000000)).toUnsigned(32);
    v[c * 2 + 1] = lo.toUnsigned(32);
    _rot(v, b, c, 11);
  }

  @override
  void _compress() {
    List<int> u512 = Blake.u512;
    List<int> v = List<int>.filled(32, 0);
    List<int> m = List<int>.filled(32, 0);
    int i = 0;
    for (; i < 32; ++i) {
      m[i] = _block.getUint32(i << 2);
    }
    for (i = 0; i < 16; ++i) {
      v[i] = _h[i].toUnsigned(32);
    }
    for (i = 16; i < 24; ++i) {
      v[i] = (_s[i - 16] ^ u512[i - 16]).toUnsigned(32);
    }
    for (i = 24; i < 32; ++i) {
      v[i] = u512[i - 16];
    }
    if (!_nullT) {
      v[24] = (v[24] ^ _length[1]).toUnsigned(32);
      v[25] = (v[25] ^ _length[0]).toUnsigned(32);
      v[26] = (v[26] ^ _length[1]).toUnsigned(32);
      v[27] = (v[27] ^ _length[0]).toUnsigned(32);
      v[28] = (v[28] ^ _length[3]).toUnsigned(32);
      v[29] = (v[29] ^ _length[2]).toUnsigned(32);
      v[30] = (v[30] ^ _length[3]).toUnsigned(32);
      v[31] = (v[31] ^ _length[2]).toUnsigned(32);
    }
    for (i = 0; i < 16; ++i) {
      _g(v, m, i, 0, 4, 8, 12, 0);
      _g(v, m, i, 1, 5, 9, 13, 2);
      _g(v, m, i, 2, 6, 10, 14, 4);
      _g(v, m, i, 3, 7, 11, 15, 6);
      _g(v, m, i, 0, 5, 10, 15, 8);
      _g(v, m, i, 1, 6, 11, 12, 10);
      _g(v, m, i, 2, 7, 8, 13, 12);
      _g(v, m, i, 3, 4, 9, 14, 14);
    }

    for (i = 0; i < 16; ++i) {
      _h[(i % 8) * 2] = (_h[(i % 8) * 2] ^ v[i * 2]).toUnsigned(32);
      _h[(i % 8) * 2 + 1] = (_h[(i % 8) * 2 + 1] ^ v[i * 2 + 1]).toUnsigned(32);
    }

    for (i = 0; i < 8; ++i) {
      _h[i * 2] = (_h[i * 2] ^ _s[(i % 4) * 2]).toUnsigned(32);
      _h[i * 2 + 1] = (_h[i * 2 + 1] ^ _s[(i % 4) * 2 + 1]).toUnsigned(32);
    }
  }

  void _padding() {
    List<int> len = _length.sublist(0);
    len[0] += _blockOffset << 3;
    _length_carry(len);
    ByteData msgLen = ByteData(16);
    for (int i = 0; i < 4; ++i) {
      msgLen.setUint32(i << 2, len[3 - i]);
    }
    if (_blockOffset == 111) {
      _length[0] -= 8;
      update(_oo);
    } else {
      if (_blockOffset < 111) {
        if (_blockOffset == 0) {
          _nullT = true;
        }
        _length[0] -= (111 - _blockOffset) << 3;
        update(Blake.padding.sublist(0, 111 - _blockOffset));
      } else {
        _length[0] -= (128 - _blockOffset) << 3;
        update(Blake.padding.sublist(0, 128 - _blockOffset));
        _length[0] -= 888;
        update(Blake.padding.sublist(1, 112));
        _nullT = true;
      }
      update(_zo);
      _length[0] -= 8;
    }
    _length[0] -= 128;
    update(msgLen.buffer.asUint8List());
  }

  @override
  Uint8List digest() {
    _padding();
    ByteData buffer = ByteData(64);
    for (int i = 0; i < 16; ++i) {
      buffer.setUint32(i << 2, _h[i]);
    }
    return buffer.buffer.asUint8List();
  }
}
