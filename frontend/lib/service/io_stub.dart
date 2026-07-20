// Stub implementation for web builds to avoid importing dart:io.
// This file is only used when dart:io is unavailable (e.g. Flutter Web).

class File {
  File(String path);

  Future<bool> exists() async => false;
}
