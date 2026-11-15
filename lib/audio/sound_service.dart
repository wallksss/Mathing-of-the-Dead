import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';

enum Sfx { shot, groan, chime, error, bite, click }

/// Plays synthesized sound effects. The sounds are generated in code (no
/// audio assets), and nothing is played unless the player enabled sound.
class SoundService {
  SoundService(this._enabled);

  final bool Function() _enabled;
  final _cache = <Sfx, Uint8List>{};
  final _players = <AudioPlayer>[];
  int _next = 0;

  static const _sampleRate = 22050;
  static const _poolSize = 4;

  Future<void> play(Sfx sfx) async {
    if (!_enabled()) return;
    try {
      if (_players.isEmpty) {
        for (var i = 0; i < _poolSize; i++) {
          _players.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
        }
      }
      final player = _players[_next];
      _next = (_next + 1) % _poolSize;
      final bytes = _cache.putIfAbsent(sfx, () => _wav(_synth(sfx)));
      await player.stop();
      await player.play(BytesSource(bytes, mimeType: 'audio/wav'), volume: 0.6);
    } catch (e) {
      // Audio is a nicety: never let it break the game.
      debugPrint('Sound error: $e');
    }
  }

  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
  }

  Float64List _synth(Sfx sfx) {
    final rnd = math.Random(sfx.index + 7);
    Float64List gen(double seconds, double Function(double t, int i) f) {
      final n = (seconds * _sampleRate).round();
      final out = Float64List(n);
      for (var i = 0; i < n; i++) {
        out[i] = f(i / _sampleRate, i);
      }
      return out;
    }

    switch (sfx) {
      case Sfx.shot:
        var low = 0.0;
        return gen(0.35, (t, _) {
          final noise = rnd.nextDouble() * 2 - 1;
          low = low * 0.6 + noise * 0.4;
          final env = math.exp(-t * 18);
          final thump = math.sin(2 * math.pi * 70 * t) * math.exp(-t * 25);
          return (low * 0.8 + thump * 0.6) * env;
        });
      case Sfx.groan:
        return gen(0.9, (t, _) {
          final vibrato = 1 + 0.05 * math.sin(2 * math.pi * 6 * t);
          final f = (95 - 25 * t) * vibrato;
          final saw = 2 * ((f * t) % 1) - 1;
          final env = math.sin(math.pi * t / 0.9);
          return saw * env * 0.45 + (rnd.nextDouble() - 0.5) * 0.05 * env;
        });
      case Sfx.chime:
        return gen(0.5, (t, _) {
          final f = t < 0.12 ? 880.0 : 1318.5;
          final local = t < 0.12 ? t : t - 0.12;
          return math.sin(2 * math.pi * f * t) * math.exp(-local * 7) * 0.5;
        });
      case Sfx.error:
        return gen(0.18, (t, _) {
          final sq = math.sin(2 * math.pi * 140 * t) >= 0 ? 1.0 : -1.0;
          return sq * 0.25 * (1 - t / 0.18);
        });
      case Sfx.bite:
        return gen(0.6, (t, _) {
          final noise = rnd.nextDouble() * 2 - 1;
          final growl = math.sin(
            2 * math.pi * (60 + 20 * math.sin(30 * t)) * t,
          );
          return (noise * 0.4 + growl * 0.6) * math.exp(-t * 4);
        });
      case Sfx.click:
        return gen(
          0.03,
          (t, _) => math.sin(2 * math.pi * 1800 * t) * (1 - t / 0.03) * 0.3,
        );
    }
  }

  /// Encodes samples in [-1, 1] as a 16-bit mono PCM WAV file.
  Uint8List _wav(Float64List samples) {
    final dataLength = samples.length * 2;
    final bytes = ByteData(44 + dataLength);
    void ascii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        bytes.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataLength, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, _sampleRate, Endian.little);
    bytes.setUint32(28, _sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    bytes.setUint32(40, dataLength, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
      bytes.setInt16(44 + i * 2, v, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService(() => ref.read(settingsProvider).soundEnabled);
  ref.onDispose(service.dispose);
  return service;
});
