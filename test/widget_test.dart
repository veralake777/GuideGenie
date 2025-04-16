import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guide_genie/main.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App initializes and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => GameProvider()),
          ChangeNotifierProvider(create: (_) => PostProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen appears
    expect(find.text('Guide Genie'), findsOneWidget);
    expect(find.text('Gaming guides at your fingertips'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
