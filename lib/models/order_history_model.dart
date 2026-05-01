class OrderHistoryItem {
  final String code;
  final String date;
  final String itemsSummary;
  final String total;
  final String status;
  final int paymentMethod;

  const OrderHistoryItem({
    required this.code,
    required this.date,
    required this.itemsSummary,
    required this.total,
    required this.status,
    required this.paymentMethod,
  });

  String? get name => null;

  String? get phone => null;

  String? get address => null;
}

const List<OrderHistoryItem> mockOrders = [
  OrderHistoryItem(
    code: '#DH24001',
    date: '20/04/2026 - 12:30',
    itemsSummary: '2x Gà rán, 1x Pepsi',
    total: '115.000đ',
    status: 'Đang giao',
    paymentMethod: 1,
  ),
  OrderHistoryItem(
    code: '#DH23980',
    date: '18/04/2026 - 19:10',
    itemsSummary: '1x Burger bò, 1x Khoai tây chiên',
    total: '98.000đ',
    status: 'Đã giao',
    paymentMethod: 2,
  ),
  OrderHistoryItem(
    code: '#DH23921',
    date: '15/04/2026 - 08:45',
    itemsSummary: '1x Cơm gà sốt cay',
    total: '49.000đ',
    status: 'Đã hủy',
    paymentMethod: 1,
  ),
];
