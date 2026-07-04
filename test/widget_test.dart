import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tictactoe/services/storage_service.dart';
import 'package:tictactoe/viewmodels/app_settings_view_model.dart';
import 'package:tictactoe/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Guest gate then continue', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    await storage.pruneEphemeralOnLaunch();

    await tester.pumpWidget(
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

    await tester.pump(const Duration(seconds: 3));
    // Splash finishes animation then [Future.delayed] before swapping screens.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Continue as Guest'), findsOneWidget);

    await tester.tap(find.text('Continue as Guest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Choose mode'), findsOneWidget);
  });
}
