import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_painter/main.dart';
import 'package:pixel_painter/screens/game_screen.dart';
import 'package:pixel_painter/widgets/cartridge_bar.dart';
import 'package:pixel_painter/widgets/cartridge_widget.dart';

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

  testWidgets('Level 27 (Kitap) starting cartridge queue matches user-defined rows', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 26),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    final expectedColors = [
      16, 31, 16,
      34, 14, 15,
      16, 14, 16,
      34, -1, 34, // Siyah can be 12, 36, or 28
      16, 31, 16,
    ];

    for (int i = 0; i < expectedColors.length; i++) {
      if (expectedColors[i] == -1) {
        expect(
          {12, 36, 28}.contains(cartridges[i].colorId),
          isTrue,
          reason: 'Cartridge at index $i should be black (12, 36, or 28) but was ${cartridges[i].colorId}',
        );
      } else {
        expect(
          cartridges[i].colorId,
          expectedColors[i],
          reason: 'Cartridge at index $i should have colorId ${expectedColors[i]} but was ${cartridges[i].colorId}',
        );
      }
    }
  });

  testWidgets('Level 28 (Corgi) cartridge queue makes most common color (32) size 30 and others 10/15/20', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 27),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    for (final c in cartridges) {
      if (c.colorId == 32) {
        expect(c.amount, 30, reason: 'Color 32 cartridges should only have amount 30');
      } else {
        expect({10, 15, 20}.contains(c.amount), isTrue, reason: 'Non-32 cartridges should only have amount 10, 15, or 20');
      }
    }
  });

  testWidgets('Level 31 (Ejderha) cartridge queue has 3 columns and capacities of mostly 20 and 30', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 30),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    print('Total cartridges generated for Level 31: ${cartridges.length}');

    // Verify 3 columns logic
    expect(cartridgeBar.columnCount, 3);

    // Verify cartridge capacities (mostly 20 and 30, with occasional 10, 15, or 25 for remainders)
    int count20or30 = 0;
    int otherCount = 0;
    for (final c in cartridges) {
      if (c.amount == 20 || c.amount == 30) {
        count20or30++;
      } else {
        otherCount++;
        expect({10, 15, 25}.contains(c.amount), isTrue, reason: 'Other cartridge amount should be 10, 15 or 25 but was ${c.amount}');
      }
    }

    final ratio = count20or30 / cartridges.length;
    print('Level 31 cartridge capacity ratio (20/30): $ratio (count: $count20or30, others: $otherCount)');
    expect(ratio > 0.8, isTrue, reason: 'At least 80% of cartridges should be 20 or 30');
  });

  testWidgets('Level 32 (index 31) cartridge queue has hideSecondRow true, hides row 1, and has Color 1 as 15/40 late in the queue', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 31),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    expect(cartridgeBar.hideSecondRow, isTrue);

    final cartridges = cartridgeBar.cartridges;

    // Verify that Color 1 has exactly two cartridges with capacities 15 and 40
    final color1Cartridges = cartridges.where((c) => c.colorId == 1).toList();
    expect(color1Cartridges.length, 2);
    expect(color1Cartridges[0].amount, 15);
    expect(color1Cartridges[1].amount, 40);

    // Verify they are positioned near the end of the queue
    final indices = color1Cartridges.map((c) => cartridges.indexOf(c)).toList();
    for (final index in indices) {
      expect(index, greaterThan(cartridges.length - 12));
    }

    // Verify that CartridgeWidget only renders for active/front row (row 0), and not row 1 (which are hidden/invisible)
    final visibleCartridges = tester.widgetList(find.byType(CartridgeWidget)).toList();
    expect(visibleCartridges.length, lessThanOrEqualTo(3));
  });

  testWidgets('Level 33 (index 32) cartridge queue has hideSecondRow true, interleaved colors, and diverse capacities', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 32),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    expect(cartridgeBar.hideSecondRow, isTrue);

    final cartridges = cartridgeBar.cartridges;
    expect(cartridges.isNotEmpty, isTrue);

    // Verify interleaving on the first 75% of the queue:
    // (At the very end of the queue, remaining colors might naturally cluster when others are finished)
    final checkLength = (cartridges.length * 0.75).round();
    for (int i = 0; i < checkLength - 1; i++) {
      expect(cartridges[i].colorId != cartridges[i + 1].colorId, isTrue,
          reason: 'Consecutive cartridges at $i and ${i + 1} have same colorId ${cartridges[i].colorId}');
    }

    // Verify first 3 cartridges (active starting slots) have distinct colors
    expect(cartridges[0].colorId != cartridges[1].colorId, isTrue);
    expect(cartridges[0].colorId != cartridges[2].colorId, isTrue);
    expect(cartridges[1].colorId != cartridges[2].colorId, isTrue);

    // Verify capacity diversity:
    // Ensure we have a mix of capacities (e.g. not all 20s)
    final amounts = cartridges.map((c) => c.amount).toSet();
    print('Level 33 unique cartridge capacities: $amounts');
    expect(amounts.length, greaterThan(1), reason: 'Should have multiple unique cartridge capacities');
    
    // The first 3 cartridges should have a mix of capacities, not all 20s
    final firstThreeAmounts = cartridges.take(3).map((c) => c.amount).toList();
    print('Level 33 first three capacities: $firstThreeAmounts');
    final hasDiversity = firstThreeAmounts.any((amount) => amount != 20);
    expect(hasDiversity, isTrue, reason: 'First three capacities should not all be 20');
  });

  testWidgets('Level 34 (index 33) cartridge queue has hideSecondRow true, interleaved colors, and diverse capacities', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 33),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    expect(cartridgeBar.hideSecondRow, isTrue);

    final cartridges = cartridgeBar.cartridges;
    expect(cartridges.isNotEmpty, isTrue);

    print('Level 34 all cartridges:');
    for (int i = 0; i < cartridges.length; i++) {
      print('  $i: ColorId=${cartridges[i].colorId}, Amount=${cartridges[i].amount}');
    }

    // Verify interleaving on the first 75% of the queue:
    // (At the very end of the queue, remaining colors might naturally cluster when others are finished)
    final checkLength = (cartridges.length * 0.75).round();
    for (int i = 0; i < checkLength - 1; i++) {
      expect(cartridges[i].colorId != cartridges[i + 1].colorId, isTrue,
          reason: 'Consecutive cartridges at $i and ${i + 1} have same colorId ${cartridges[i].colorId}');
    }

    // Verify first 3 cartridges (active starting slots) have distinct colors
    expect(cartridges[0].colorId != cartridges[1].colorId, isTrue);
    expect(cartridges[0].colorId != cartridges[2].colorId, isTrue);
    expect(cartridges[1].colorId != cartridges[2].colorId, isTrue);

    // Verify capacity diversity:
    // Ensure we have a mix of capacities (e.g. not all 20s)
    final amounts = cartridges.map((c) => c.amount).toSet();
    print('Level 34 unique cartridge capacities: $amounts');
    expect(amounts.length, greaterThan(1));
    
    // Ensure no 5-round cartridges exist and only allowed capacities are used
    expect(cartridges.any((c) => c.amount == 5), isFalse, reason: 'Should not contain 5-round cartridges');
    expect(cartridges.every((c) => [10, 15, 20, 30, 40].contains(c.amount)), isTrue, reason: 'Only 10, 15, 20, 30, 40 are allowed');

    // The first 3 cartridges should have a mix of capacities, not all 20s
    final firstThreeAmounts = cartridges.take(3).map((c) => c.amount).toList();
    print('Level 34 first three capacities: $firstThreeAmounts');
    final hasDiversity = firstThreeAmounts.any((amount) => amount != 20);
    expect(hasDiversity, isTrue, reason: 'First three capacities should not all be 20');
  });

  testWidgets('Debug Level 34 swaps step-by-step', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(initialLevelIndex: 33),
    ));
    await tester.pumpAndSettle();

    final cartridgeBarFinder = find.byType(CartridgeBar);
    expect(cartridgeBarFinder, findsOneWidget);

    final cartridgeBar = tester.widget<CartridgeBar>(cartridgeBarFinder);
    final cartridges = cartridgeBar.cartridges;

    final positionsToCheck = [2, 12, 14, 17, 18, 22, 34, 55, 57, 60, 67, 71];
    print('--- Cartridges at Swapped Positions (1-indexed) ---');
    for (final pos in positionsToCheck) {
      final c = cartridges[pos];
      print('${pos + 1}. Sıra: Renk=${c.colorId} (${c.name}), Miktar=${c.amount}');
    }
    print('--------------------------------------------------');
  });
}


