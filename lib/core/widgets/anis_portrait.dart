import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../theme/app_colors.dart';
import 'study_avatar.dart';

/// The face of the home screen.
///
/// If `assets/anis.jpg` exists it's shown as a soft circular portrait with a
/// rose ring — drop in his photo, or any picture you'd rather use, at that
/// path. Otherwise the drawn doctor-studying avatar is shown, which already
/// comes with its own backdrop and so isn't cropped into a circle.
class AnisPortrait extends StatefulWidget {
  const AnisPortrait({super.key, this.size = 170, this.asset = 'assets/anis.jpg'});

  final double size;
  final String asset;

  @override
  State<AnisPortrait> createState() => _AnisPortraitState();
}

class _AnisPortraitState extends State<AnisPortrait> {
  late final Future<bool> _hasPhoto = _lookForPhoto();

  Future<bool> _lookForPhoto() async {
    try {
      await rootBundle.load(widget.asset);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPhoto,
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return StudyAvatar(size: widget.size);
        }
        return _CircularPhoto(size: widget.size, asset: widget.asset);
      },
    );
  }
}

class _CircularPhoto extends StatelessWidget {
  const _CircularPhoto({required this.size, required this.asset});

  final double size;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: scheme.primary.withValues(alpha: 0.55), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rose.withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
          ),
          Positioned(
            right: 2,
            bottom: 6,
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
              child: const Icon(Icons.favorite, color: AppColors.heart, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
