import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool soundEnabled = true;

  // Web は dart:io が使えないため UrlSource、ネイティブは AssetSource を使う
  Source _source(String path) => kIsWeb
      ? UrlSource('assets/$path')
      : AssetSource(path);

  Future<void> _play(String path) async {
    if (!soundEnabled) return;
    final player = AudioPlayer();
    await player.play(_source(path));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  Future<void> playPlaceO() => _play('sounds/place_o.wav');
  Future<void> playPlaceX() => _play('sounds/place_x.wav');
  Future<void> playWin() => _play('sounds/win.wav');
  Future<void> playDraw() => _play('sounds/draw.wav');
}
