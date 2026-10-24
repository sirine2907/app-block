import 'package:equatable/equatable.dart';

/// The collection of sweet messages "from Sirine", loaded from
/// `assets/love_notes.json`.
class LoveNotes extends Equatable {
  const LoveNotes({
    required this.signature,
    required this.notes,
    required this.sessionComplete,
    required this.milestones,
  });

  final String signature;
  final List<String> notes;
  final List<String> sessionComplete;
  final Map<String, String> milestones;

  static const LoveNotes empty = LoveNotes(
    signature: '— Sirine',
    notes: ['You have got this.'],
    sessionComplete: ['You did it!'],
    milestones: {},
  );

  @override
  List<Object?> get props => [signature, notes, sessionComplete, milestones];
}
