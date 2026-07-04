import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'services/storage_service.dart';
import 'viewmodels/app_settings_view_model.dart';
import 'views/guest_screen.dart';
import 'views/home_screen.dart';
import 'views/splash_screen.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final storage = await StorageService.create();
  await storage.pruneEphemeralOnLaunch();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(
          create: (_) => AppSettingsViewModel(storage),
        ),
      ],
      child: const TicTacToeRoot(),
    ),
  );
}

class TicTacToeRoot extends StatefulWidget {
  const TicTacToeRoot({super.key});

  @override
  State<TicTacToeRoot> createState() => _TicTacToeRootState();
}

class _TicTacToeRootState extends State<TicTacToeRoot> {
  var _splashVisible = true;

  void _onSplashFinished() {
    setState(() => _splashVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _splashVisible
            ? SplashScreen(
                key: const ValueKey('splash'),
                onFinished: _onSplashFinished,
              )
            : _MainGate(key: const ValueKey('main')),
      ),
    );
  }
}

class _MainGate extends StatelessWidget {
  const _MainGate({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: settings.guestEntered
          ? const HomeScreen(key: ValueKey('home'))
          : const GuestScreen(key: ValueKey('guest')),
    );
  }
}
