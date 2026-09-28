import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wa_tracker/main.dart';
import 'package:wa_tracker/models/winter_arc_model.dart';
import 'package:wa_tracker/providers/arc_provider.dart';

class MockArcNotifier extends ArcNotifier {
  final WinterArc initial;
  MockArcNotifier(this.initial);

  @override
  WinterArc build() => initial;
}

void main() {
  testWidgets('App renders splash and transitions to onboarding when not onboarded', (WidgetTester tester) async {
    final arc = WinterArc.defaultArc();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          arcProvider.overrideWith(() => MockArcNotifier(arc)),
        ],
        child: const WinterArcApp(),
      ),
    );

    // Verify splash screen appears initially
    expect(find.text('Winter Arc Tracker'), findsOneWidget);
    expect(find.text('DISCIPLINE • ROUTINE • MASTERY'), findsOneWidget);

    // Settle splash timer and transition
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify onboarding screen is presented
    expect(find.text('WINTER ARC'), findsWidgets);
    expect(find.text('Set Your Challenge'), findsOneWidget);
    expect(find.text('Start My Winter Arc'), findsOneWidget);
  });
}
