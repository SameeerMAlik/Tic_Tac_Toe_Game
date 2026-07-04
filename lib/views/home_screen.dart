import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_page_routes.dart';
import '../models/game_mode.dart';
import '../services/storage_service.dart';
import '../viewmodels/app_settings_view_model.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/app_logo.dart';
import '../widgets/staggered_reveal.dart';
import '../widgets/styled_top_bar.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _toast;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = context.read<StorageService>();
      final msg = storage.takeLastResult();
      if (msg != null && mounted) {
        setState(() => _toast = msg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = context.watch<AppSettingsViewModel>();
    final storage = context.read<StorageService>();
    final scores = storage.loadScores();

    return Scaffold(
      appBar: StyledTopBar.home(
        context: context,
        isDarkMode: settings.isDarkMode,
        onToggleTheme: () => settings.toggleTheme(),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withValues(alpha: 0.07),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth.clamp(320.0, 520.0);
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_toast != null) ...[
                          _ResultBanner(
                            message: _toast!,
                            onDismiss: () => setState(() => _toast = null),
                          ),
                          const SizedBox(height: 16),
                        ],
                        StaggeredReveal(
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.22),
                                    blurRadius: 22,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: AnimatedAppLogo(
                                  size: 72,
                                  motion: LogoMotion.breatheAndFloat,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        StaggeredReveal(
                          delay: const Duration(milliseconds: 40),
                          child: Text(
                            'Scores',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        StaggeredReveal(
                          delay: const Duration(milliseconds: 110),
                          child: _ScoreRow(scores: scores),
                        ),
                        const SizedBox(height: 8),
                        StaggeredReveal(
                          delay: const Duration(milliseconds: 160),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Reset scores?'),
                                    content: const Text(
                                      'This clears win counts on this device.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Reset'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true && context.mounted) {
                                  await storage.saveScores(x: 0, o: 0, draw: 0);
                                  setState(() {});
                                }
                              },
                              child: const Text('Reset scores'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        StaggeredReveal(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            'Choose mode',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        StaggeredReveal(
                          delay: const Duration(milliseconds: 240),
                          child: _ModeCard(
                            icon: Icons.groups_2_outlined,
                            title: 'Player vs Player',
                            subtitle: GameMode.playerVsPlayer.subtitle,
                            color: cs.primary,
                            onTap: () => _openGame(context, GameMode.playerVsPlayer),
                          ),
                        ),
                        const SizedBox(height: 12),
                        StaggeredReveal(
                          delay: const Duration(milliseconds: 300),
                          child: _ModeCard(
                            icon: Icons.shuffle,
                            title: 'Player vs AI',
                            subtitle: GameMode.playerVsAiRandom.subtitle,
                            color: cs.secondary,
                            onTap: () => _openGame(context, GameMode.playerVsAiRandom),
                          ),
                        ),
                        const SizedBox(height: 12),
                        StaggeredReveal(
                          delay: const Duration(milliseconds: 360),
                          child: _ModeCard(
                            icon: Icons.psychology_outlined,
                            title: 'Player vs Smart AI',
                            subtitle: GameMode.playerVsAiSmart.subtitle,
                            color: cs.tertiary,
                            onTap: () => _openGame(context, GameMode.playerVsAiSmart),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openGame(BuildContext context, GameMode mode) {
    Navigator.of(context)
        .push<void>(
      AppPageRoutes.fadeSlide<void>(
        ChangeNotifierProvider(
          create: (_) => GameViewModel(
            storage: context.read<StorageService>(),
            mode: mode,
          ),
          child: GameScreen(mode: mode),
        ),
      ),
    )
        .then((_) {
      if (mounted) setState(() {});
    });
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Material(
        key: ValueKey(message),
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: cs.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Last game: $message',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: cs.onPrimaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.scores});

  final ({int x, int o, int draw}) scores;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: _pill(context, 'X', '${scores.x}', cs.primary)),
        const SizedBox(width: 10),
        Expanded(child: _pill(context, 'O', '${scores.o}', cs.secondary)),
        const SizedBox(width: 10),
        Expanded(child: _pill(context, 'Draw', '${scores.draw}', cs.tertiary)),
      ],
    );
  }

  Widget _pill(BuildContext context, String label, String value, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent.withValues(alpha: 0.15),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        elevation: Theme.of(context).brightness == Brightness.dark ? 3 : 1,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (pressed) {
            setState(() => _scale = pressed ? 0.985 : 1);
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: widget.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
