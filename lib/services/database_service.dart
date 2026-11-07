import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';

/// Service class to handle all database operations with Firestore.
class DatabaseService {
  /// Pass a Firestore instance to use a different database (tests use a fake one).
  /// When omitted, the app's real Firestore is used.
  DatabaseService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  /// Mock User ID for demonstration. In a real app, this would come from an Auth service.
  final String userId = "user_12345";

  /// Returns the reference to the user's addresses collection in Firestore.
  CollectionReference<Map<String, dynamic>> get addressCollection {
    return _db.collection('users').doc(userId).collection('addresses');
  }

  /// Adds a new address to Firestore.
  Future<void> addAddress(AddressModel address) async {
    final doc = await addressCollection.add(address.toMap());
    if (address.isDefault) await setDefaultAddress(doc.id);
  }

  /// Updates an existing address in Firestore.
  Future<void> updateAddress(AddressModel address) async {
    if (address.id == null) return;
    await addressCollection.doc(address.id).update(address.toMap());
    if (address.isDefault) await setDefaultAddress(address.id!);
  }

  /// Makes one address the default and clears the flag on all the others,
  /// in a single batch so there is never more than one default.
  Future<void> setDefaultAddress(String id) async {
    final snapshot = await addressCollection.get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == id});
    }
    await batch.commit();
  }

  /// Deletes an address from Firestore using its document ID.
  Future<void> deleteAddress(String id) async {
    await addressCollection.doc(id).delete();
  }

  /// Returns a stream of AddressModel lists for real-time updates.
  Stream<List<AddressModel>> getAddresses() {
    return addressCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AddressModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Generates mock order data for UI demonstration.
  List<OrderModel> getMockOrders() {
    return [
      OrderModel(
          id: "2324252627",
          date: DateTime(2023, 11, 25),
          status: OrderStatus.confirmed),
      OrderModel(
          id: "2324252628",
          date: DateTime(2023, 11, 24),
          status: OrderStatus.processing),
      OrderModel(
          id: "2324252629",
          date: DateTime(2023, 11, 20),
          status: OrderStatus.shipping),
      OrderModel(
          id: "2324252630",
          date: DateTime(2023, 11, 12),
          status: OrderStatus.delivery),
      OrderModel(
          id: "2324252631",
          date: DateTime(2023, 11, 3),
          status: OrderStatus.cancelled),
    ];
  }
}
