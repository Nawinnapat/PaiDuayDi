import 'package:flutter_test/flutter_test.dart';
import 'package:paiduaydi/main.dart';
import 'package:flutter/material.dart';
import 'package:paiduaydi/features/auth/presentation/screens/home_inside_feature_screen.dart';

void main() {
  testWidgets('App loads splash screen and transitions to auth entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PaiDuayDiApp());
    expect(find.text('PaiDuayDi'), findsOneWidget);

    // Advance timer to trigger transition to AuthEntryScreen
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('ดำเนินการต่อด้วย Facebook'), findsOneWidget);
    expect(find.text('ดำเนินการต่อด้วย Google'), findsOneWidget);
  });
  testWidgets('Create Trip screen matches the destination selection flow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeInsideFeatureScreen(
          originName: 'มธ. รังสิต',
          destinationName: 'Future Park Rangsit',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('When?'), findsOneWidget);
    expect(find.text('Share Taxi'), findsOneWidget);
    expect(find.text('People needed'), findsOneWidget);
    expect(find.text('Trip Preferences'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text('+ 30 min'));
    await tester.pumpAndSettle();
    expect(find.text('+ 30 min'), findsOneWidget);
  });
}
