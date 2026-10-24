import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../theme/app_colors.dart';

/// The face of the home screen: Anis at his desk, mid-study.
///
/// Shows the bundled illustration, framed in a rose-edged card with a little
/// heart in the corner. If `assets/anis.jpg` exists it takes over instead —
/// drop his photo in at that path and nothing else needs changing.
class AnisPortrait extends StatefulWidget {
  const AnisPortrait({
    super.key,
    this.size = 170,
    this.photo = 'assets/anis.jpg',
  });

  final double size;

  /// Optional photo that replaces the illustration when the file is there.
  final String photo;

  @override
  State<AnisPortrait> createState() => _AnisPortraitState();
}

class _AnisPortraitState extends State<AnisPortrait> {
  static const _illustration = 'assets/anis_studying.jpg';

  late final Future<bool> _hasPhoto = _lookForPhoto();

  Future<bool> _lookForPhoto() async {
    try {
      await rootBundle.load(widget.photo);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Crops the tall illustration to a square around him: close enough that he
  /// fills the frame, and stopping just above his open notes, where the
  /// lettering in the picture sits upside down.
  Widget _croppedIllustration() => Transform.scale(
        scale: 1.65,
        alignment: const Alignment(0.36, -1),
        child: const Image(
          image: AssetImage(_illustration),
          fit: BoxFit.cover,
          alignment: Alignment(0, -0.71),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(widget.size * 0.17);

    return FutureBuilder<bool>(
      future: _hasPhoto,
      builder: (context, snapshot) {
        final usePhoto = snapshot.data == true;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.rose.withValues(alpha: 0.25),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                // Drawn over the image so the ring lines up with the corners.
                foregroundDecoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.7),
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: usePhoto
                      ? Image.asset(widget.photo, fit: BoxFit.cover)
                      : _croppedIllustration(),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rose.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.favorite, color: AppColors.heart, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
