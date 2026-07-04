import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_assets.dart';

/// Static logo from [AppAssets.logo].
class AppLogoImage extends StatelessWidget {
  const AppLogoImage({
    super.key,
    required this.size,
    this.fit = BoxFit.cover,
    this.clipCircular = false,
  });

  final double size;
  final BoxFit fit;
  final bool clipCircular;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      AppAssets.logo,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      semanticLabel: 'Tic Tac Toe logo',
    );
    if (clipCircular) {
      image = ClipOval(child: image);
    }
    return image;
  }
}

enum LogoMotion {
  /// No looping animation (still usable inside parent animations).
  none,

  /// Subtle scale pulse.
  breathe,

  /// Scale pulse + gentle vertical drift (nice on menus).
  breatheAndFloat,
}

/// Asset logo with smooth looping motion driven by [motion].
class AnimatedAppLogo extends StatefulWidget {
  const AnimatedAppLogo({
    super.key,
    required this.size,
    this.motion = LogoMotion.breatheAndFloat,
    this.clipCircular = true,
  });

  final double size;
  final LogoMotion motion;
  final bool clipCircular;

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    if (widget.motion != LogoMotion.none) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedAppLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.motion == LogoMotion.none && _controller.isAnimating) {
      _controller.stop();
    } else if (widget.motion != LogoMotion.none && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.motion == LogoMotion.none) {
      return AppLogoImage(
        size: widget.size,
        clipCircular: widget.clipCircular,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value * math.pi * 2;
        double scale = 1;
        double dy = 0;

        switch (widget.motion) {
          case LogoMotion.breathe:
            scale = 1 + 0.052 * math.sin(phase);
          case LogoMotion.breatheAndFloat:
            scale = 1 + 0.048 * math.sin(phase);
            dy = 4.2 * math.cos(phase * 0.82);
          case LogoMotion.none:
            break;
        }

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: AppLogoImage(
              size: widget.size,
              clipCircular: widget.clipCircular,
            ),
          ),
        );
      },
    );
  }
}
