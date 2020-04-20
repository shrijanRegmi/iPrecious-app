import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class Music {
  AudioCache _cache = AudioCache(prefix: "music/");

  playMusic() async {
    AudioPlayer _player = await _cache.loop("fearless.mp3");
    return _player;
  }

  stopMusic(AudioPlayer _player) async {
    await _player.stop();
  }

  pauseMusic(AudioPlayer _player) async {
    await _player.pause();
  }

  resumeMusic(AudioPlayer _player) async {
    await _player.resume();
  }
}
