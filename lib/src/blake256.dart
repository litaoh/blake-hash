part of blake_hash;

Uint8List zo = Uint8List.fromList([0x01]);
Uint8List oo = Uint8List.fromList([0x81]);

class Blake256 extends Blake {
  List<int> _s;
  bool _nullt;
  Blake256() {
    reset();
  }

  @override
  void reset() {
    _h = [
      0x6a09e667,
      0xbb67ae85,
      0x3c6ef372,
      0xa54ff53a,
      0x510e527f,
      0x9b05688c,
      0x1f83d9ab,
      0x5be0cd19
    ];

    _s = [0, 0, 0, 0];

    _block = ByteData(64);

    _blockOffset = 0;
    _length = [0, 0];

    _nullt = false;
    _zo = zo;
    _oo = oo;
  }

  int _rotr32(int x, int n) => (x >> n) | ((x << (32 - n)) & 0xffffffff);

  int _add32(int x, int y) => (x + y) & 0xffffffff;

  void _g(List<int> v, List<int> m, int i, int a, int b, int c, int d, int e) {
    var sigma = Blake.sigma;
    var u256 = Blake.u256;
    v[a] = _add32(v[a], _add32(m[sigma[i][e]] ^ u256[sigma[i][e + 1]], v[b]));
    v[d] = _rotr32(v[d] ^ v[a], 16);
    v[c] = _add32(v[c], v[d]);
    v[b] = _rotr32(v[b] ^ v[c], 12);
    v[a] = _add32(v[a], _add32(m[sigma[i][e + 1]] ^ u256[sigma[i][e]], v[b]));
    v[d] = _rotr32(v[d] ^ v[a], 8);
    v[c] = _add32(v[c], v[d]);
    v[b] = _rotr32(v[b] ^ v[c], 7);
  }

  @override
  void _compress() {
    var u256 = Blake.u256;
    var v = List<int>(16);
    var m = List<int>(16);

    for (var i = 0; i < 16; ++i) {
      m[i] = _block.getUint32(i * 4);
    }

    for (var i = 0; i < 8; ++i) {
      v[i] = _h[i];
    }
    for (var i = 8; i < 12; ++i) {
      v[i] = (_s[i - 8] ^ u256[i - 8]);
    }
    for (var i = 12; i < 16; ++i) {
      v[i] = u256[i - 8];
    }
    if (!_nullt) {
      v[12] ^= _length[0];
      v[13] ^= _length[0];
      v[14] ^= _length[1];
      v[15] ^= _length[1];
    }

    for (var i = 0; i < 14; ++i) {
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

    for (var i = 0; i < 16; ++i) {
      _h[i % 8] ^= v[i];
    }
    for (var i = 0; i < 8; ++i) {
      _h[i] ^= _s[i % 4];
    }
  }

  void _padding() {
    var lo = _length[0] + _blockOffset * 8;
    var hi = _length[1];
    if (lo >= 0x0100000000) {
      lo -= 0x0100000000;
      hi += 1;
    }

    var msgLen = ByteData(8);

    msgLen.setUint32(0, hi);

    msgLen.setUint32(4, lo);

    if (_blockOffset == 55) {
      _length[0] -= 8;
      update(_oo);
    } else {
      if (_blockOffset < 55) {
        if (_blockOffset == 0) _nullt = true;
        _length[0] -= (55 - _blockOffset) * 8;
        update(Blake.padding.sublist(0, 55 - _blockOffset));
      } else {
        _length[0] -= (64 - _blockOffset) * 8;
        update(Blake.padding.sublist(0, 64 - _blockOffset));
        _length[0] -= 55 * 8;
        update(Blake.padding.sublist(1, 1 + 55));
        _nullt = true;
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
    var buffer = ByteData(32);

    for (var i = 0; i < 8; ++i) {
      buffer.setUint32(i * 4, _h[i]);
    }
    return buffer.buffer.asUint8List();
  }
}
