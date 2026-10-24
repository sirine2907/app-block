import 'dart:async';

import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

/// Thin, typed wrapper around the native Android [MethodChannel] and
/// [EventChannel].
///
/// This is the only place in the Dart code that talks to Kotlin directly.
/// Repositories depend on this class, never on [MethodChannel] itself, which
/// keeps the data layer easy to fake in tests.
class FocusChannel {
  FocusChannel({MethodChannel? methodChannel, EventChannel? eventChannel})
      : _method = methodChannel ?? const MethodChannel(AppConstants.methodChannel),
        _event = eventChannel ?? const EventChannel(AppConstants.eventChannel);

  final MethodChannel _method;
  final EventChannel _event;

  Stream<Map<String, dynamic>>? _stateStream;

  /// A broadcast stream of native session-state updates.
  Stream<Map<String, dynamic>> get sessionStateStream {
    _stateStream ??= _event
        .receiveBroadcastStream()
        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
        .asBroadcastStream();
    return _stateStream!;
  }

  /// Returns the current native session state as a raw map.
  Future<Map<String, dynamic>> getState() async {
    final result = await _method.invokeMethod<Map<dynamic, dynamic>>('getState');
    return Map<String, dynamic>.from(result ?? const {});
  }

  /// Starts a cheat-proof focus session that cannot be cancelled.
  Future<bool> startSession({
    required int durationMs,
    required List<String> packages,
  }) async {
    final ok = await _method.invokeMethod<bool>('startSession', {
      'durationMs': durationMs,
      'packages': packages,
    });
    return ok ?? false;
  }

  /// Tells native we've shown the completion screen so it can clear it.
  Future<void> acknowledgeCompletion() =>
      _method.invokeMethod<void>('acknowledgeCompletion');

  /// Caches the love notes natively so the block screen can show them offline.
  Future<void> cacheLoveNotes({
    required List<String> notes,
    required List<String> completeNotes,
    required String signature,
  }) =>
      _method.invokeMethod<void>('cacheLoveNotes', {
        'notes': notes,
        'completeNotes': completeNotes,
        'signature': signature,
      });

  /// Returns the status of every permission the app needs.
  Future<Map<String, bool>> checkPermissions() async {
    final result =
        await _method.invokeMethod<Map<dynamic, dynamic>>('checkPermissions');
    return (result ?? const {})
        .map((key, value) => MapEntry(key.toString(), value == true));
  }

  /// Opens the system screen that grants [permission].
  Future<void> requestPermission(String permission) =>
      _method.invokeMethod<void>('requestPermission', {'permission': permission});

  /// Returns the installed, launchable apps with icons as base64 PNG.
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    final result =
        await _method.invokeMethod<List<dynamic>>('getInstalledApps');
    return (result ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
