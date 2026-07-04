import 'package:flutter/material.dart';

import 'app_logo.dart';

/// Shared chrome for primary screens: gradient wash, accent hairline, depth.
abstract final class StyledTopBar {
  static AppBar home({
    required BuildContext context,
    required bool isDarkMode,
    required VoidCallback onToggleTheme,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppBar(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 6,
      toolbarHeight: 60,
      shadowColor: cs.primary.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: const _FlexibleChrome(),
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withValues(alpha: 0.28),
                  cs.secondary.withValues(alpha: 0.14),
                ],
              ),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.38),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.grid_3x3_rounded,
              color: cs.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Play',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Offline · Same device',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: isDarkMode ? 'Light mode' : 'Dark mode',
              onPressed: onToggleTheme,
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: cs.primary,
              ),
            ),
          ),
        ),
      ],
      bottom: _accentDivider(context),
    );
  }

  static AppBar game({
    required BuildContext context,
    required String modeTitle,
    required VoidCallback onBack,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppBar(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 6,
      toolbarHeight: 60,
      shadowColor: cs.primary.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: const _FlexibleChrome(),
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton.filledTonal(
          style: IconButton.styleFrom(
            backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.65),
            foregroundColor: cs.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: cs.outline.withValues(alpha: 0.35)),
            ),
          ),
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      titleSpacing: 4,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.28),
                  blurRadius: 14,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.35),
              ),
            ),
            child: AnimatedAppLogo(
              size: 30,
              motion: LogoMotion.breathe,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  modeTitle,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Match in progress',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: _accentDivider(context),
    );
  }

  static PreferredSize _accentDivider(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(2),
      child: SizedBox(
        height: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    cs.primary.withValues(alpha: 0.55),
                    cs.secondary.withValues(alpha: 0.42),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1,
                color: cs.outline.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlexibleChrome extends StatelessWidget {
  const _FlexibleChrome();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.22),
            cs.secondary.withValues(alpha: 0.08),
            bg,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
    );
  }
}
