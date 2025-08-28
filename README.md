# Flutter Audio Player with Sound Effects

A **modern and interactive audio player app** built with Flutter. This app allows users to play local audio files or online streams, control playback speed, loop audio, and apply fun sound effects like pitch shift, faster/slower playback, and more.

---

![Flutter Audio Player](https://raw.githubusercontent.com/your-username/flutter-audio-player/main/assets/screenshots/home_screen.png)

---

## Features

- **Play audio from local storage or URL**
- **Pause, stop, skip tracks** (next/previous functionality placeholders)
- **Loop/repeat audio**
- **Adjust playback speed**
- **Sound effects screen**:
  - Pitch Up / Pitch Down
  - Faster / Slower
  - Darth Vader / Squirrel
  - Reset to Normal
- **Beautiful and responsive UI** with gradient backgrounds and interactive controls
- **File picker support** to select local audio files
- **Playback progress slider** with current time & total duration
- **Permission handling** for media and storage access

---

## Screenshots

### Home Screen
![Home Screen](assets/screenshots/home_screen.png)

### Sound Effects Screen
![Sound Effects Screen](assets/screenshots/sound_effects_screen.png)

---

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart
- Android Studio or VS Code
- Physical device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/flutter-audio-player.git
cd flutter-audio-player

Install dependencies:
flutter pub get

Run the app:
flutter run

Permissions
The app requests the following permissions for proper functionality:
Storage/Media: To pick audio files from local storage.
Microphone/Audio: Required for sound effects on some platforms.

These are handled automatically using the permission_handler
 package.
Packages Used

audioplayers
 – For audio playback

just_audio
 – For advanced sound effect playback

file_picker
 – To select audio files from storage

permission_handler
 – For runtime permissions

Usage

Open the app and tap the music library icon to select a local audio file.

Play or pause the track using the central button.

Adjust playback speed using the slider.

Tap the equalizer icon to access the Sound Effects screen and apply effects.

Press Save to apply the effect and return to the main screen.

Toggle Repeat mode with the repeat button.

Use the slider to seek the audio to any position.

Project Structure
lib/
 ├─ main.dart                 # App entry point
 ├─ home_screen.dart           # Main audio player screen
 └─ sound_effects_screen.dart  # Sound effects UI & logic
assets/
 └─ screenshots/               # App screenshots for README

Future Improvements

Implement previous/next track functionality

Add playlist support

Save edited audio files locally

Add visual audio spectrum/animations

Improve error handling and user notifications
