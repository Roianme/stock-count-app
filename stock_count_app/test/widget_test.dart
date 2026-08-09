import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_count_app/model/item_model.dart';
import 'package:stock_count_app/view/widgets/item_card_widget.dart';

Item makeItem({
  required ItemStatus status,
  Set<ItemStatus> enabled = const {ItemStatus.quantity, ItemStatus.dropdown},
  List<ItemUnitOptionRecord> opts = const [
    ItemUnitOptionRecord(label: 'opt-a'),
    ItemUnitOptionRecord(label: 'opt-b'),
  ],
  String? unit,
  int? qty,
}) {
  return Item(
    id: 999, name: 'Test', category: Category.misc,
    status: status, unitOptions: opts,
    unit: unit, quantity: qty, enabledStatuses: enabled,
  );
}

Future<void> pumpCard(WidgetTester t, {required Item item}) async {
  await t.pumpWidget(MaterialApp(home: Scaffold(body: ItemCardWidget(
    item: item, statusControlWidth: 120, hideIcon: true,
    isListView: true, showItemNameInColumn: true,
    onCheckChanged: () {}, onQuantityChanged: (_) {},
    onStatusChanged: (_) {}, onUnitChanged: (_) {},
  ))));
  await t.pumpAndSettle();
}

void main() {
  group('Item.copyWith', () {
    test('preserves qty when only status changed', () {
      final item = makeItem(status: ItemStatus.quantity, qty: 42);
      final u = item.copyWith(status: ItemStatus.urgent);
      expect(u.quantity, equals(42));
    });
    test('preserves unit when only status changed', () {
      final item = makeItem(status: ItemStatus.dropdown, unit: 'opt-a');
      final u = item.copyWith(status: ItemStatus.quantity);
      expect(u.unit, equals('opt-a'));
    });
  });

  group('three-dot menu', () {
    testWidgets('shows options not Dropdown word', (t) async {
      await pumpCard(t, item: makeItem(status: ItemStatus.quantity));
      await t.tap(find.byIcon(Icons.more_vert));
      await t.pumpAndSettle();
      expect(find.text('Dropdown'), findsNothing);
      expect(find.text('opt-a'), findsOneWidget);
      expect(find.text('opt-b'), findsOneWidget);
    });

    testWidgets('hides selected option from menu', (t) async {
      await pumpCard(t, item: makeItem(
        status: ItemStatus.dropdown, unit: 'opt-a',
      ));
      await t.tap(find.byIcon(Icons.more_vert));
      await t.pumpAndSettle();
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('opt-b'), findsOneWidget);
    });

    testWidgets('divider between status and options', (t) async {
      await pumpCard(t, item: makeItem(
        status: ItemStatus.quantity,
        enabled: const {ItemStatus.quantity, ItemStatus.dropdown, ItemStatus.urgent},
      ));
      await t.tap(find.byIcon(Icons.more_vert));
      await t.pumpAndSettle();
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('no menu when single status no options', (t) async {
      await pumpCard(t, item: makeItem(
        status: ItemStatus.quantity,
        enabled: const {ItemStatus.quantity},
        opts: const [],
      ));
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });
  });

  group('callbacks', () {
    testWidgets('dropdown option fires both callbacks', (t) async {
      ItemStatus? sc;
      ItemUnitOptionRecord? uc;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: ItemCardWidget(
        item: makeItem(status: ItemStatus.quantity),
        statusControlWidth: 120, hideIcon: true,
        isListView: true, showItemNameInColumn: true,
        onCheckChanged: () {}, onQuantityChanged: (_) {},
        onStatusChanged: (s) => sc = s,
        onUnitChanged: (u) => uc = u,
      ))));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.more_vert));
      await t.pumpAndSettle();
      await t.tap(find.text('opt-a'));
      await t.pumpAndSettle();
      expect(sc, equals(ItemStatus.dropdown));
      expect(uc?.label, equals('opt-a'));
    });

    testWidgets('Quantity from menu in dropdown mode', (t) async {
      ItemStatus? sc;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: ItemCardWidget(
        item: makeItem(
          status: ItemStatus.dropdown, unit: 'opt-a',
        ),
        statusControlWidth: 120, hideIcon: true,
        isListView: true, showItemNameInColumn: true,
        onCheckChanged: () {}, onQuantityChanged: (_) {},
        onStatusChanged: (s) => sc = s,
        onUnitChanged: (_) {},
      ))));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.more_vert));
      await t.pumpAndSettle();
      await t.tap(find.text('Quantity'));
      await t.pumpAndSettle();
      expect(sc, equals(ItemStatus.quantity));
    });
  });
}
