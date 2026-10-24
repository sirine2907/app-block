import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/heart_logo.dart';
import '../../../../injection_container.dart';
import '../../../permissions/presentation/bloc/permissions_cubit.dart';
import '../../../permissions/presentation/pages/permissions_page.dart';

/// A soft, three-slide welcome that ends with a prominent disclosure of why
/// the app needs its permissions, then leads into the checklist.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone});

  /// Called once onboarding and permissions are complete.
  final VoidCallback onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      title: 'Hi Anis 💗',
      body:
          'Sirine made you this little app. It helps you focus by gently '
          'blocking the apps that pull you away — just for a while.',
    ),
    _Slide(
      title: 'Focus, protected',
      body:
          'Once you start a session, it can\'t be cancelled, ended early, or '
          'uninstalled. The only way out is to finish. That\'s the whole point.',
    ),
    _Slide(
      title: 'Before we begin',
      body:
          'To keep your focus safe, For Anis needs a few Android permissions: '
          'Accessibility, Device Admin, Usage Access, Display over other apps, '
          'Battery optimization and Notifications. The next screen explains each '
          'one and lets you grant them. Nothing you type is ever read or shared.',
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _openPermissions();
    }
  }

  void _openPermissions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => sl<PermissionsCubit>(),
          child: PermissionsPage(
            onAllGranted: () {
              Navigator.of(context).pop();
              widget.onDone();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HeartLogo(size: 110),
                          const SizedBox(height: 36),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.displayMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            slide.body,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _page < _slides.length - 1
                          ? 'Next'
                          : 'Set up permissions',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.title, required this.body});

  final String title;
  final String body;
}
