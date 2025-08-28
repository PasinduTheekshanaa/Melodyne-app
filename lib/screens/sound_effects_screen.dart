import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundEffectsScreen extends StatefulWidget {
  final String currentFilePath;

  const SoundEffectsScreen({super.key, required this.currentFilePath});

  @override
  State<SoundEffectsScreen> createState() => _SoundEffectsScreenState();
}

class _SoundEffectsScreenState extends State<SoundEffectsScreen> {
  String? _activeEffect;
  final AudioPlayer _player = AudioPlayer();

  final List<Map<String, dynamic>> effects = [
    {
      "name": "Pitch Up",
      "desc": "Raise pitch (chipmunk)",
      "id": "pitch_up",
      "pitch": 1.3,
      "speed": 1.0,
    },
    {
      "name": "Pitch Down",
      "desc": "Lower pitch (deep voice)",
      "id": "pitch_down",
      "pitch": 0.7,
      "speed": 1.0,
    },
    {
      "name": "Faster",
      "desc": "Increase speed",
      "id": "faster",
      "pitch": 1.0,
      "speed": 1.3,
    },
    {
      "name": "Slower",
      "desc": "Decrease speed",
      "id": "slower",
      "pitch": 1.0,
      "speed": 0.7,
    },
    {
      "name": "Normal",
      "desc": "Reset to normal playback",
      "id": "normal",
      "pitch": 1.0,
      "speed": 1.0,
    },
    {
      "name": "Darth Vader",
      "desc": "Dark & slow voice",
      "id": "darth_vader",
      "pitch": 0.6,
      "speed": 0.8,
    },
    {
      "name": "Squirrel",
      "desc": "Funny fast chipmunk",
      "id": "squirrel",
      "pitch": 1.6,
      "speed": 1.4,
    },
  ];

  Future<void> _toggleEffect(String effectId) async {
    final effect = effects.firstWhere((e) => e["id"] == effectId);
    setState(() => _activeEffect = effectId);
    await _player.stop();
    await _player.setFilePath(widget.currentFilePath);
    try {
      await _player.setPitch(effect["pitch"] as double);
    } catch (_) {}
    await _player.setSpeed(effect["speed"] as double);
    await _player.play();
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.setFilePath(widget.currentFilePath);
    await _player.setPitch(1.0);
    await _player.setSpeed(1.0);
  }

  @override
  void dispose() {
    _player.stop();

    _player.dispose(); // cleanup only when screen is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Purple → Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Sound Effects",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Effects grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: effects.length,
                  itemBuilder: (context, index) {
                    final effect = effects[index];
                    final isActive = _activeEffect == effect["id"];
                    return GestureDetector(
                      onTap: () => _toggleEffect(effect["id"] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF6A11CB),
                                    Color(0xFF2575FC),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Colors.black87, Colors.black54],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          boxShadow: [
                            if (isActive)
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? Icons.music_note : Icons.music_off,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              effect["name"] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              effect["desc"] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            if (isActive)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF6A11CB), // Purple
                    ),
                    onPressed: () async {
                      if (_activeEffect != null) {
                        final effect = effects.firstWhere(
                          (e) => e["id"] == _activeEffect,
                        );
                        await _player.stop(); // just stop preview
                        Navigator.pop(context, effect);
                      } else {
                        await _player.stop();
                        Navigator.pop(context, null);
                      }
                    },

                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
