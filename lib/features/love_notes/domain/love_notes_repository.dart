import 'love_notes.dart';

/// Loads the love notes and exposes helpers for picking a message.
abstract class LoveNotesRepository {
  /// Loads the notes from the bundled asset (cached after first read).
  Future<LoveNotes> load();

  /// A random "keep going" note, used on the block and active screens.
  Future<String> randomNote();

  /// A random celebratory message for the session-complete screen.
  Future<String> randomCompleteMessage();

  /// The signature appended to notes, e.g. "— Sirine 💗".
  Future<String> signature();
}
