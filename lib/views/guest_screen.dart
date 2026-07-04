import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_settings_view_model.dart';
import '../widgets/app_logo.dart';
import '../widgets/staggered_reveal.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.12),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.28, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                StaggeredReveal(
                  duration: const Duration(milliseconds: 520),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.28),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: AnimatedAppLogo(
                      size: 104,
                      motion: LogoMotion.breatheAndFloat,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                StaggeredReveal(
                  delay: const Duration(milliseconds: 90),
                  child: Text(
                    'Tic Tac Toe',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                StaggeredReveal(
                  delay: const Duration(milliseconds: 170),
                  child: Text(
                    'Play offline on one device. '
                    'Pick a friend or challenge the AI.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.45,
                        ),
                  ),
                ),
                const Spacer(flex: 3),
                StaggeredReveal(
                  delay: const Duration(milliseconds: 260),
                  child: FilledButton(
                    onPressed: () async {
                      await context.read<AppSettingsViewModel>().setGuestEntered();
                    },
                    child: const Text('Continue as Guest'),
                  ),
                ),
                const SizedBox(height: 12),
                StaggeredReveal(
                  delay: const Duration(milliseconds: 340),
                  child: Text(
                    'No account — nothing leaves your phone.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
