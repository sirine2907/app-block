import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../../../core/platform/focus_channel.dart';
import '../domain/love_notes.dart';
import '../domain/love_notes_repository.dart';

/// Loads the love notes from `assets/love_notes.json`, caches them in memory,
/// and mirrors them to the native layer so the block screen can show a note
/// even when the Flutter engine isn't running.
class LoveNotesRepositoryImpl implements LoveNotesRepository {
  LoveNotesRepositoryImpl({
    required FocusChannel channel,
    Random? random,
    String assetPath = 'assets/love_notes.json',
  })  : _channel = channel,
        _random = random ?? Random(),
        _assetPath = assetPath;

  final FocusChannel _channel;
  final Random _random;
  final String _assetPath;

  LoveNotes? _cache;

  @override
  Future<LoveNotes> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final notes = LoveNotes(
      signature: json['signature'] as String? ?? '— Sirine',
      notes: (json['notes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      sessionComplete: (json['session_complete'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      milestones: (json['milestones'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, value.toString())),
    );
    _cache = notes;
    // Best-effort: push to native so the block activity can read them.
    try {
      await _channel.cacheLoveNotes(
        notes: notes.notes,
        completeNotes: notes.sessionComplete,
        signature: notes.signature,
      );
    } catch (_) {
      // Native not available (e.g. in tests); ignore.
    }
    return notes;
  }

  @override
  Future<String> randomNote() async {
    final data = await load();
    if (data.notes.isEmpty) return '';
    return data.notes[_random.nextInt(data.notes.length)];
  }

  @override
  Future<String> randomCompleteMessage() async {
    final data = await load();
    if (data.sessionComplete.isEmpty) return 'You did it!';
    return data.sessionComplete[_random.nextInt(data.sessionComplete.length)];
  }

  @override
  Future<String> signature() async => (await load()).signature;
}
