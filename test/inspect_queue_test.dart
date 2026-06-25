import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_painter/main.dart';
import 'package:pixel_painter/screens/game_screen.dart';
import 'package:pixel_painter/widgets/cartridge_bar.dart';

void main() {
  testWidgets('Level 16 cartridge queue matches Google Sheets repeating pattern', (
    WidgetTester tester,
  ) async {
    // Set surface size to prevent overflow warnings in test output
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Load the game screen for Level 16 (index 15)
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 15),
    ));
    await tester.pumpAndSettle();

    // Find the CartridgeBar
    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    print('Total cartridges generated: ${cartridges.length}');

    // Expected sequence of colorIds for the first few cartridges:
    // Row 1: 103 (Krem), 104 (Krem Desen), 11 (Beyaz)
    // Row 2: 93 (Bordo), 103 (Krem), 97 (Sarı)
    // Row 3: 103 (Krem), 42 (Açık Kahve), 97 (Sarı)
    // Row 4: 93 (Bordo), 103 (Krem), 100 (Siyah)
    // Row 5: 103 (Krem), 104 (Krem Desen), 47 (Koyu Kahve)
    // Row 6: 42 (Açık Kahve), 103 (Krem), 97 (Sarı)
    // Row 7: 103 (Krem), 104 (Krem Desen), 11 (Beyaz)
    final expectedColors = [
      103, 104, 11,
      93, 103, 97,
      103, 42, 97,
      93, 103, 100,
      103, 104, 47,
      42, 103, 97,
      103, 104, 11,
    ];

    for (int i = 0; i < expectedColors.length; i++) {
      expect(
        cartridges[i].colorId,
        expectedColors[i],
        reason: 'Cartridge at index $i (1-indexed row/col) should match expected colorId',
      );
    }

    // Print the first 21 cartridge details for visual confirmation
    final names = {
      103: "Krem",
      104: "Krem Desen",
      11: "Beyaz",
      100: "Siyah",
      42: "Açık Kahve",
      47: "Koyu Kahve",
      93: "Bordo",
      97: "Sarı",
    };

    for (int i = 0; i < 21 && i < cartridges.length; i += 3) {
      final chunk = cartridges.skip(i).take(3).toList();
      final chunkStrs = chunk.map((c) => '${names[c.colorId]}(${c.amount})').join(' ');
      print('Row ${(i ~/ 3) + 1}: $chunkStrs');
    }
  });

  testWidgets('Level 22 cartridge queue has teal cartridges sorted first and having amounts of 40/30', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Load the game screen for Level 22 (index 21)
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 21),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    print('Total cartridges generated for Level 22: ${cartridges.length}');

    final names = {
      21: "Koyu Teal",
      22: "Orta Teal",
      23: "Canli Teal",
      12: "Siyah Outline",
      140: "Metal Koyu",
      141: "Metal Acik",
      136: "Yakit Kirmizi/Altin",
      138: "Kil Kahve Acik",
      137: "Guard Detail",
      135: "Grip Detail",
    };

    print('First 20 cartridges for Level 22:');
    for (int i = 0; i < 20; i++) {
      final name = names[cartridges[i].colorId] ?? 'Color ${cartridges[i].colorId}';
      print('$i: $name(${cartridges[i].amount})');
    }

    final tealColorIds = {21, 22, 23};
    
    // The first 6 cartridges must be teal
    for (int i = 0; i < 6; i++) {
      expect(
        tealColorIds.contains(cartridges[i].colorId),
        isTrue,
        reason: 'The first cartridge at index $i should be a Teal color but was ${cartridges[i].colorId}',
      );
    }

    // At least 14 out of the first 20 cartridges must be teal (dominant)
    int tealCount = 0;
    for (int i = 0; i < 20; i++) {
      if (tealColorIds.contains(cartridges[i].colorId)) {
        tealCount++;
        expect(
          cartridges[i].amount == 40 || cartridges[i].amount == 30,
          isTrue,
          reason: 'Teal cartridge at index $i should have amount 40 or 30 but was ${cartridges[i].amount}',
        );
      } else {
        expect(
          cartridges[i].amount == 20 || cartridges[i].amount == 10,
          isTrue,
          reason: 'Non-teal cartridge at index $i should have amount 20 or 10 but was ${cartridges[i].amount}',
        );
      }
    }
    expect(tealCount >= 14, isTrue, reason: 'Teal cartridges should be dominant (>= 14 out of 20)');
  });

  testWidgets('Level 23 cartridge queue has only 10 and 20 round cartridges (no 30/40s)', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Load the game screen for Level 23 (index 22)
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 22),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    print('Total cartridges generated for Level 23: ${cartridges.length}');

    // Every cartridge must have amount 10 or 20
    for (int i = 0; i < cartridges.length; i++) {
      expect(
        cartridges[i].amount == 10 || cartridges[i].amount == 20,
        isTrue,
        reason: 'Cartridge at index $i should have amount 10 or 20 but was ${cartridges[i].amount}',
      );
    }

    // At least 30 cartridges must be 10-round
    final tensCount = cartridges.where((c) => c.amount == 10).length;
    expect(
      tensCount >= 30,
      isTrue,
      reason: 'Should have at least 30 10-round cartridges but had $tensCount',
    );
  });

  testWidgets('Level 25 cartridge queue has 60% 10-round, 20% 15-round, 20% 20-round cartridges', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Load the game screen for Level 25 (index 24)
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 24),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    print('Total cartridges generated for Level 25: ${cartridges.length}');

    final tens = cartridges.where((c) => c.amount == 10).length;
    final fifteens = cartridges.where((c) => c.amount == 15).length;
    final twenties = cartridges.where((c) => c.amount == 20).length;

    print('Tens: $tens, Fifteens: $fifteens, Twenties: $twenties');

    expect(cartridges.length, 70);
    expect(tens, 42); // 60% of 70
    expect(fifteens, 14); // 20% of 70
    expect(twenties, 14); // 20% of 70
  });
}
