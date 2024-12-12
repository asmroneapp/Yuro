import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:asmrapp/core/audio/i_audio_player_service.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'dart:async';

class Track {
  final String title;
  final String artist;
  final String coverUrl;

  Track({
    required this.title,
    required this.artist,
    required this.coverUrl,
  });
}

class PlayerViewModel extends ChangeNotifier {
  final IAudioPlayerService _audioService = GetIt.I<IAudioPlayerService>();

  bool _isPlaying = false;
  Track? _currentTrack;
  Duration? _position;
  Duration? _duration;
  Subtitle? _currentSubtitle;

  final List<StreamSubscription> _subscriptions = [];

  PlayerViewModel() {
    _initStreams();
    _initCurrentTrack();
  }

  void _initCurrentTrack() {
    final currentTrack = _audioService.currentTrack;
    if (currentTrack != null) {
      _currentTrack = Track(
        title: currentTrack.title,
        artist: currentTrack.artist,
        coverUrl: currentTrack.coverUrl,
      );
      notifyListeners();
    }

    _audioService.playerState.first.then((state) {
      if (state.playing || state.processingState == ProcessingState.ready) {
        _isPlaying = state.playing;
        notifyListeners();
      }
    });
  }

  void _initStreams() {
    try {
      _subscriptions.add(
        _audioService.playerState.listen(
          (state) {
            _isPlaying = state.playing;
            final currentTrack = _audioService.currentTrack;
            if (currentTrack != null) {
              _currentTrack = Track(
                title: currentTrack.title,
                artist: currentTrack.artist,
                coverUrl: currentTrack.coverUrl,
              );
            }
            notifyListeners();
          },
          onError: (error) {
            debugPrint('播放状态流错误: $error');
          },
        ),
      );

      _subscriptions.add(
        _audioService.position.listen(
          (pos) {
            _position = pos;
            _updateSubtitle();
            notifyListeners();
          },
          onError: (error) {
            debugPrint('播放进度流错误: $error');
          },
        ),
      );

      _subscriptions.add(
        _audioService.duration.listen(
          (dur) {
            _duration = dur;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('音频时长流错误: $error');
          },
        ),
      );
    } catch (e) {
      debugPrint('初始化流失败: $e');
    }
  }

  void _updateSubtitle() {
    final subtitleList = _audioService.subtitleList;
    debugPrint('字幕列表状态: ${subtitleList != null ? '已加载' : '未加载'}');
    
    if (subtitleList != null && _position != null) {
      final newSubtitle = subtitleList.getCurrentSubtitle(_position!);
      debugPrint('当前播放位置: ${_position!.inSeconds}秒, 找到字幕: ${newSubtitle?.text ?? '无'}');
      
      if (_currentSubtitle?.text != newSubtitle?.text) {
        _currentSubtitle = newSubtitle;
        debugPrint('字幕更新: ${newSubtitle?.text ?? '无字幕'}');
        notifyListeners();
      }
    }
  }

  bool get isPlaying => _isPlaying;
  Track? get currentTrack => _currentTrack;
  Duration? get position => _position;
  Duration? get duration => _duration;
  Subtitle? get currentSubtitle => _currentSubtitle;

  Future<void> playPause() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> previous() async {
    await _audioService.previous();
  }

  Future<void> next() async {
    await _audioService.next();
  }

  Future<void> stop() async {
    await _audioService.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  void setTrack(Track track) {
    _currentTrack = track;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
