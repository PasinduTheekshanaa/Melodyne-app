import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sound_effects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isRepeating = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  double _currentPlaybackSpeed = 1.0;

  String? currentFilePath;
  String? currentFileName;

  final String defaultUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (!isRepeating) {
        setState(() {
          isPlaying = false;
          position = Duration.zero;
        });
      }
    });
    _audioPlayer.setPlaybackRate(_currentPlaybackSpeed);
  }

  void playAudio({String? path}) async {
    if (path != null) {
      await _audioPlayer.play(DeviceFileSource(path));
      currentFilePath = path;
    } else {
      await _audioPlayer.play(UrlSource(defaultUrl));
    }
    setState(() => isPlaying = true);
    await _audioPlayer.setPlaybackRate(_currentPlaybackSpeed);
  }

  void pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  void stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      position = Duration.zero;
    });
  }

  Future<void> pickAudioFile() async {
    if (await Permission.mediaLibrary.request().isGranted ||
        await Permission.audio.request().isGranted ||
        await Permission.storage.request().isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        String name = result.files.single.name;

        setState(() {
          currentFilePath = path;
          currentFileName = name;
        });

        playAudio(path: path);
      }
    } else {
      openAppSettings();
    }
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Top Row for the Sound Effects Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.graphic_eq, color: Colors.white),
                      onPressed: () async {
                        if (currentFilePath == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select a song first!",
                                style: TextStyle(color: Colors.black87),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          );
                          return;
                        }

                        final effect = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SoundEffectsScreen(
                              currentFilePath: currentFilePath!,
                            ),
                          ),
                        );

                        if (effect != null && effect is Map<String, dynamic>) {
                          final newSpeed = effect["speed"] as double;
                          setState(() {
                            _currentPlaybackSpeed = newSpeed;
                          });

                          await _audioPlayer.setPlaybackRate(newSpeed);

                          // Resume playback if it was paused
                          if (!isPlaying) {
                            playAudio(path: currentFilePath);
                          }
                        }
                      },
                    ),
                  ],
                ),

                // Music Icon container
                Expanded(
                  child: Center(
                    child: Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.deepPurple.shade200,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.music_note,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Song Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentFileName ?? "SoundHelix Song",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        currentFilePath != null
                            ? "From Storage"
                            : "Artist Name",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble().clamp(
                          0,
                          duration.inSeconds.toDouble(),
                        ),
                        onChanged: (value) async {
                          final newPosition = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(newPosition);
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatTime(position),
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            formatTime(duration - position),
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Playback Speed Slider
                Column(
                  children: [
                    Text(
                      'Playback Speed: ${_currentPlaybackSpeed.toStringAsFixed(1)}x',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Slider(
                      min: 0.5,
                      max: 2.0,
                      divisions: 3,
                      value: _currentPlaybackSpeed,
                      onChanged: (value) async {
                        setState(() {
                          _currentPlaybackSpeed = value;
                        });
                        await _audioPlayer.setPlaybackRate(value);
                      },
                      activeColor: Colors.amber,
                      inactiveColor: Colors.amber.shade200,
                      label: '${_currentPlaybackSpeed.toStringAsFixed(1)}x',
                    ),
                  ],
                ),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.library_music,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: pickAudioFile,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {},
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 50,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            pauseAudio();
                          } else {
                            playAudio(path: currentFilePath);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {},
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: isRepeating ? Colors.white : Colors.white70,
                        size: 28,
                      ),
                      onPressed: () async {
                        setState(() {
                          isRepeating = !isRepeating;
                        });
                        await _audioPlayer.setReleaseMode(
                          isRepeating ? ReleaseMode.loop : ReleaseMode.stop,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
