import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paiduaydi/core/services/route_service.dart';
import 'package:paiduaydi/features/auth/presentation/screens/home_inside_feature_screen.dart';
import 'package:paiduaydi/features/auth/presentation/screens/matching_screen.dart';
import 'package:paiduaydi/main.dart';

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

    final startButton = find.widgetWithText(FilledButton, 'Start');
    await tester.ensureVisible(startButton);
    await tester.pumpAndSettle();
    tester.widget<FilledButton>(startButton).onPressed!.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Searching for matches...'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Matching screen reveals candidates after searching', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MatchingScreen(
          originName: 'รังสิต',
          destinationName: 'อนุสาวรีย์ชัยฯ',
          originLocation: const LatLng(13.75, 100.5),
          destinationLocation: const LatLng(13.76, 100.51),
          route: const RouteDetails(
            encodedPolyline: '',
            distanceMeters: 1500,
            durationSeconds: 600,
          ),
          estimatedCost: 50,
          departureDateTime: DateTime(2026, 10, 18, 17, 30),
          searchDelay: Duration(milliseconds: 10),
        ),
      ),
    );

    expect(find.text('Searching for matches...'), findsOneWidget);
    expect(find.text('Krit P.'), findsNothing);

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Krit P.'), findsOneWidget);
    expect(find.text('Nara S.'), findsOneWidget);
    expect(find.text('ขอร่วมทาง'), findsNWidgets(2));

    await tester.tap(find.text('ขอร่วมทาง').first);
    await tester.pumpAndSettle();
    expect(find.text('จับคู่สำเร็จแล้ว!'), findsOneWidget);
    expect(find.text('รังสิต'), findsWidgets);
    expect(find.text('อนุสาวรีย์ชัยฯ'), findsWidgets);
    expect(find.text('50 BAHT / คน'), findsOneWidget);
    expect(find.text('ยืนยันเข้าร่วมทริป'), findsOneWidget);
    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(
      map.markers.map((marker) => marker.position),
      contains(const LatLng(13.75, 100.5)),
    );
    expect(
      map.markers.map((marker) => marker.position),
      contains(const LatLng(13.76, 100.51)),
    );
    expect(map.scrollGesturesEnabled, isTrue);
    expect(map.zoomGesturesEnabled, isTrue);

    await tester.tap(find.byTooltip('ขยายแผนที่'));
    await tester.pumpAndSettle();
    expect(find.text('แผนที่เส้นทาง'), findsOneWidget);
    final fullScreenMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(fullScreenMap.scrollGesturesEnabled, isTrue);
    expect(fullScreenMap.zoomGesturesEnabled, isTrue);

    await tester.pumpWidget(const SizedBox());
  });
}
