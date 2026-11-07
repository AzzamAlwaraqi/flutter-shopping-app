import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/database_service.dart';

/// Screen that displays a categorized list of user orders.
class MyOrderPage extends StatelessWidget {
  const MyOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch mock orders from service
    final List<OrderModel> orders = DatabaseService().getMockOrders();
    
    // Categorize orders based on their status
    final runningOrders = orders
        .where((o) =>
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.shipping)
        .toList();
    final previousOrders = orders
        .where((o) =>
            o.status == OrderStatus.delivery ||
            o.status == OrderStatus.cancelled)
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "My Order",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "All (${orders.length})"),
              Tab(text: "Running (${runningOrders.length})"),
              Tab(text: "Previous (${previousOrders.length})"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(orders: orders),
            _OrderList(orders: runningOrders),
            _OrderList(orders: previousOrders),
          ],
        ),
      ),
    );
  }
}

/// Internal helper widget to display a list of order cards.
class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

/// Internal widget representing an individual order card with a status bar.
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  /// Logic to determine the primary color based on order status.
  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.confirmed:
        return const Color(0xFF3F51B5);
      case OrderStatus.processing:
        return Colors.green;
      case OrderStatus.shipping:
        return Colors.orange;
      case OrderStatus.delivery:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// Order date as "25 Nov".
  static String _shortDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  /// Human-readable text for order status.
  String get _statusText {
    switch (order.status) {
      case OrderStatus.confirmed:
        return "Confirmed";
      case OrderStatus.processing:
        return "Processing";
      case OrderStatus.shipping:
        return "Shipped";
      case OrderStatus.delivery:
        return "Delivery";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order ID: ${order.id}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                _shortDate(order.date),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Status",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildStatusBar(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _statusText,
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a visual progress bar indicating the order status.
  Widget _buildStatusBar() {
    int activeIndex = 0;
    if (order.status == OrderStatus.confirmed) activeIndex = 0;
    if (order.status == OrderStatus.processing) activeIndex = 1;
    if (order.status == OrderStatus.shipping) activeIndex = 2;
    if (order.status == OrderStatus.delivery) activeIndex = 3;
    if (order.status == OrderStatus.cancelled) activeIndex = -1;

    return Row(
      children: [
        _dot(0, activeIndex, order.status),
        _line(0, activeIndex, order.status),
        _dot(1, activeIndex, order.status),
        _line(1, activeIndex, order.status),
        _dot(2, activeIndex, order.status),
        _line(2, activeIndex, order.status),
        _dot(3, activeIndex, order.status),
      ],
    );
  }

  Widget _dot(int index, int activeIndex, OrderStatus status) {
    bool isActive = status == OrderStatus.cancelled ? true : index <= activeIndex;
    Color color = status == OrderStatus.cancelled
        ? Colors.red
        : (isActive ? _statusColor : Colors.grey.shade300);

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _line(int index, int activeIndex, OrderStatus status) {
    bool isActive = status == OrderStatus.cancelled ? true : index < activeIndex;
    Color color = status == OrderStatus.cancelled
        ? Colors.red
        : (isActive ? _statusColor : Colors.grey.shade300);

    return Expanded(
      child: Container(
        height: 3,
        color: color,
      ),
    );
  }
}
