import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_project/models/address_model.dart';
import 'package:flutter_project/pages/add_edit_address_page.dart';
import 'package:flutter_project/pages/delivery_address_page.dart';
import 'package:flutter_project/pages/profile_page.dart';
import 'package:flutter_project/services/database_service.dart';

AddressModel sampleAddress(String street, {bool isDefault = false}) => AddressModel(
      fullName: 'Azzam Alwaraqi',
      phoneNumber: '0790000001',
      addressLine1: street,
      addressLine2: '',
      city: 'Amman',
      state: 'Amman',
      zipCode: '11942',
      isDefault: isDefault,
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late DatabaseService db;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    db = DatabaseService(firestore: firestore);
  });

  Future<void> openFromProfile(WidgetTester tester, String item) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(name: 'Azzam Alwaraqi', database: db)));
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  Future<List<AddressModel>> saved() => db.getAddresses().first;

  group('DatabaseService', () {
    test('only one address is ever the default', () async {
      await db.addAddress(sampleAddress('First St', isDefault: true));
      await db.addAddress(sampleAddress('Second St', isDefault: true));

      final defaults = (await saved()).where((a) => a.isDefault).toList();
      expect(defaults, hasLength(1));
      expect(defaults.single.addressLine1, 'Second St');
    });

    test('update and delete change the stored address', () async {
      await db.addAddress(sampleAddress('Old St'));
      final address = (await saved()).single;

      await db.updateAddress(AddressModel(
        id: address.id, fullName: address.fullName, phoneNumber: address.phoneNumber,
        addressLine1: 'New St', addressLine2: '', city: 'Irbid', state: 'Irbid', zipCode: '21110',
      ));
      expect((await saved()).single.city, 'Irbid');

      await db.deleteAddress(address.id!);
      expect(await saved(), isEmpty);
    });
  });

  testWidgets('profile shows the name and the three options', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(name: 'Azzam Alwaraqi', database: db)));
    expect(find.text('Azzam Alwaraqi'), findsOneWidget);
    for (final item in ['My Profile', 'My Order', 'Delivery Address']) {
      expect(find.text(item), findsOneWidget);
    }
  });

  testWidgets('a new name from Edit profile comes back to the profile', (tester) async {
    await openFromProfile(tester, 'My Profile');
    await tester.enterText(find.byType(TextFormField).at(0), 'Sara');
    await tester.enterText(find.byType(TextFormField).at(1), 'Haddad');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Only the name is required now, so this saves without phone, birthday or password
    expect(find.text('Sara Haddad'), findsOneWidget);
  });

  testWidgets('orders are split into running and previous, with their own dates', (tester) async {
    await openFromProfile(tester, 'My Order');
    expect(find.text('All (5)'), findsOneWidget);
    expect(find.text('Running (3)'), findsOneWidget);
    expect(find.text('Previous (2)'), findsOneWidget);
    expect(find.text('24 Nov'), findsOneWidget);

    await tester.tap(find.text('Previous (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Shipped'), findsNothing);
  });

  testWidgets('the saved default address is the selected one', (tester) async {
    await db.addAddress(sampleAddress('First St'));
    await db.addAddress(sampleAddress('Second St', isDefault: true));
    await openFromProfile(tester, 'Delivery Address');

    final group = tester.widget<RadioGroup<String>>(find.byType(RadioGroup<String>));
    final defaultId = (await saved()).firstWhere((a) => a.isDefault).id;
    expect(group.groupValue, defaultId);
    expect(find.text('Default'), findsOneWidget);
  });

  testWidgets('tapping another radio makes it the default', (tester) async {
    await db.addAddress(sampleAddress('First St', isDefault: true));
    await db.addAddress(sampleAddress('Second St'));
    await openFromProfile(tester, 'Delivery Address');

    await tester.tap(find.byType(Radio<String>).at(1));
    await tester.pumpAndSettle();

    final defaults = (await saved()).where((a) => a.isDefault).toList();
    expect(defaults.single.addressLine1, 'Second St');
  });

  testWidgets('a failed load shows an error, not an empty list', (tester) async {
    await tester.pumpWidget(MaterialApp(home: DeliveryAddressPage(database: _FailingService())));
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't load your addresses"), findsOneWidget);
    expect(find.text('No addresses found. Add one!'), findsNothing);
  });

  testWidgets('new address form validates every field', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AddEditAddressPage(database: db)));
    await tester.ensureVisible(find.text('SAVE ADDRESS'));
    await tester.tap(find.text('SAVE ADDRESS'));
    await tester.pumpAndSettle();
    expect(find.text('Required field'), findsNWidgets(7));
  });

  testWidgets('saving twice quickly adds the address once', (tester) async {
    await openFromProfile(tester, 'Delivery Address');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final values = ['Test Person', '0790000000', 'Rainbow St 5', 'Flat 1', 'Amman', 'Amman', '11181'];
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), values[i]);
    }
    await tester.ensureVisible(find.text('SAVE ADDRESS'));
    await tester.tap(find.text('SAVE ADDRESS'));
    await tester.tap(find.text('SAVE ADDRESS'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.textContaining('Rainbow St 5'), findsOneWidget);
    expect(await saved(), hasLength(1));
  });

  testWidgets('a failed save shows a message and keeps the form open', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AddEditAddressPage(database: _FailingService())));
    final values = ['Test Person', '0790000000', 'Rainbow St 5', 'Flat 1', 'Amman', 'Amman', '11181'];
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), values[i]);
    }
    await tester.ensureVisible(find.text('SAVE ADDRESS'));
    await tester.tap(find.text('SAVE ADDRESS'));
    await tester.pumpAndSettle();

    expect(find.textContaining("Couldn't save the address"), findsOneWidget);
    expect(find.text('SAVE ADDRESS'), findsOneWidget);
  });
}

/// A service whose every Firestore call fails, like having no connection.
class _FailingService extends DatabaseService {
  _FailingService() : super(firestore: FakeFirebaseFirestore());

  @override
  Stream<List<AddressModel>> getAddresses() => Stream.error(Exception('offline'));

  @override
  Future<void> addAddress(AddressModel address) async => throw Exception('offline');
}
