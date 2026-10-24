import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:for_anis/core/utils/duration_format.dart';
import 'package:for_anis/core/utils/greeting.dart';
import 'package:for_anis/core/widgets/love_note_card.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    // Don't hit the network for fonts during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('LoveNoteCard shows the note and signature', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoveNoteCard(
            note: 'Not now, Anis. You have got this.',
            signature: '— Sirine 💗',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Not now, Anis. You have got this.'), findsOneWidget);
    expect(find.text('— Sirine 💗'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  group('DurationFormat', () {
    test('clock pads to HH:MM:SS', () {
      expect(DurationFormat.clock(const Duration(hours: 1, minutes: 2, seconds: 3)),
          '01:02:03');
      expect(DurationFormat.clock(Duration.zero), '00:00:00');
    });

    test('friendly reads nicely', () {
      expect(DurationFormat.friendly(const Duration(minutes: 45)), '45 min');
      expect(DurationFormat.friendly(const Duration(hours: 1, minutes: 30)),
          '1 h 30 min');
      expect(DurationFormat.friendly(const Duration(hours: 2)), '2 h');
    });
  });

  group('Greeting', () {
    test('varies by time of day and always greets Anis', () {
      expect(Greeting.forHour(9), contains('Good morning'));
      expect(Greeting.forHour(14), contains('Good afternoon'));
      expect(Greeting.forHour(20), contains('Good evening'));
      expect(Greeting.forHour(9), contains('Anis'));
    });
  });
}
