import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:for_anis/core/widgets/study_avatar.dart';

/// Renders the avatar to a PNG so it can be eyeballed while designing it.
/// Regenerate with: flutter test test/goldens --update-goldens
void main() {
  testWidgets('study avatar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFFFF7F3),
          body: Center(child: StudyAvatar(size: 320, animate: false)),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(StudyAvatar),
      matchesGoldenFile('study_avatar.png'),
    );
  });
}
