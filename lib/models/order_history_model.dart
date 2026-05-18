class OrderHistoryItem {
  final String userId; // ID người dùng sở hữu đơn hàng
  final String code; // Mã đơn hàng
  final String date; // Ngày giờ đặt
  final String itemsSummary; // Tóm tắt sản phẩm
  final String total; // Tổng tiền
  final String status; // Trạng thái đơn hàng
  final int paymentMethod; // 1: COD, 2: MoMo
  final String name; // Tên người đặt
  final String phone; // Số điện thoại
  final String address; // Địa chỉ giao hàng

  const OrderHistoryItem({
    required this.userId,
    required this.code,
    required this.date,
    required this.itemsSummary,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.name,
    required this.phone,
    required this.address,
  });
}
