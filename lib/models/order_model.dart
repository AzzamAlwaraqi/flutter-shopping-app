/// Represents the various stages of an order lifecycle.
enum OrderStatus { 
  confirmed, 
  processing, 
  shipping, 
  delivery, 
  cancelled 
}

/// Data model representing an Order in the system.
class OrderModel {
  /// Unique identifier for the order.
  final String id;
  
  /// The date when the order was placed.
  final DateTime date;
  
  /// Current status of the order.
  final OrderStatus status;

  OrderModel({
    required this.id, 
    required this.date, 
    required this.status
  });
}
