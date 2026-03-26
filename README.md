# TeaHee

TeaHee is a minimalist, tea-themed diary/journaling app for capturing memories with text and media, built using Flutter.

## Terminology

- **TeaCups**: Individual journal entries
- **Recipes**: Entry templates:
  - **Tall**: Text-only
  - **Grande**: Text + Image-only
  - **Venti**: Text + Image/Audio/Video

## Features

Automatically convert:

- double hyphens (--) to em-dashes (—).
- standard quotes to smart quotes.

Local storage:

- Journal entries are stored as JSON files.
- Media files are copied to the app directory.

Backup and Restore:

- Export full backup of entries and media.
- Import entries and media from backup directory.

## User Installation

**Android**:

1. Download the latest `.apk` file from the releases section.
2. **Enable Unknown Sources**: If you haven't already, enable "Install from Unknown Sources" in your Android settings.
3. **Install**: Open the `.apk` file and follow the on-screen prompts.
4. **Permissions**: The app will request access to your storage and media files to save your journal entries and attachments.

## For Developers

### Prerequisites

- **Flutter SDK**: Use the latest stable version of Flutter.
- **IDE**: Android Studio or VS Code with Flutter and Dart extensions.
- **Device**: A physical Android device or emulator.

### Getting Started

1. **Clone the repository**: `git clone https://github.com/rlpvin/teahee.git`
2. **Fetch dependencies**: `flutter pub get`
3. **Run the app**: `flutter run`

### Structure

- `lib/models/teacup.dart`: core data model for entries, JSON serialization
- `lib/services/storage_service.dart`: file system operations, JSON persistence, media sandboxing
- `lib/screens/`: primary application flows:
  - `home_screen.dart`: recipe selection
  - `list_screen.dart`: view all entries
  - `edit_screen.dart`: dynamic editor based on recipe type
  - `details_screen.dart`: view entry with media preview

### Build

**Android APK:**

```bash
flutter build apk --release
```

**Android AppBundle:**

```bash
flutter build appbundle --release
```
