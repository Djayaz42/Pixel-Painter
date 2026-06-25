import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pixel_painter/main.dart';
import 'package:pixel_painter/widgets/cartridge_widget.dart';

const _allowedPackageTexts = {'10', '15', '20', '30', '40'};
const _disallowedPackageTexts = {
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '50',
};

void main() {
  testWidgets('Pixel Painter starts without the default counter demo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PixelPainterApp());

    expect(find.text('Pixel Painter'), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
  });

  testWidgets('cartridges start as small pressure batches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PixelPainterApp());
    await _openFirstLevel(tester);

    expect(find.byType(CartridgeWidget), findsWidgets);
    _expectNoDisallowedPackageText();
    expect(
      _allowedPackageTexts.any(
        (amount) => find.text(amount).evaluate().isNotEmpty,
      ),
      isTrue,
    );
  });

  testWidgets('cartridge queue shows two rows of three cartridges', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PixelPainterApp());
    await _openFirstLevel(tester);

    _expectVisibleCartridgeCountBetween(4, 6);
    expect(_hiddenCartridgeFinder(), findsNothing);

    await tester.tap(_visibleCartridgeFinder().first);
    await tester.pump();

    _expectVisibleCartridgeCountBetween(4, 6);
    expect(_hiddenCartridgeFinder(), findsNothing);
    _expectNoDisallowedPackageText();
  });

  testWidgets('queued cards keep allowed package sizes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PixelPainterApp());
    await _openFirstLevel(tester);

    _expectNoDisallowedPackageText();

    // Start one card; later queue syncs should keep using allowed package
    // sizes instead of arbitrary remaining counts like 2, 6, or 8.
    await tester.tap(_activeCartridgeFinder().first);
    await tester.pump(const Duration(seconds: 7));

    expect(find.byType(CartridgeWidget), findsWidgets);
    _expectNoDisallowedPackageText();
  });
}

Future<void> _openFirstLevel(WidgetTester tester) async {
  await tester.tap(find.text('Kalp'));
  await tester.pumpAndSettle();
}

void _expectNoDisallowedPackageText() {
  for (final disallowedAmount in _disallowedPackageTexts) {
    expect(
      find.descendant(
        of: find.byType(CartridgeWidget),
        matching: find.text(disallowedAmount),
      ),
      findsNothing,
    );
  }
}

Finder _activeCartridgeFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is CartridgeWidget && !widget.isHidden,
  );
}

Finder _visibleCartridgeFinder() => _activeCartridgeFinder();

Finder _hiddenCartridgeFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is CartridgeWidget && widget.isHidden,
  );
}

void _expectVisibleCartridgeCountBetween(int min, int max) {
  final count = _visibleCartridgeFinder().evaluate().length;
  expect(count, greaterThanOrEqualTo(min));
  expect(count, lessThanOrEqualTo(max));
}
