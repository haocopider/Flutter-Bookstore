import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/auth.dart';
import 'login_page.dart';
import 'order_history_page.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<AuthController>();

    final primaryColor = Colors.lightBlueAccent[200]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Hồ sơ cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: GetBuilder<AuthController>(
        id: 'user_profile',
        builder: (controller) {
          if (controller.currentUser == null) {
            return _buildUnauthenticatedView(primaryColor);
          }
          return _buildAuthenticatedView(controller, primaryColor);
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("Bạn chưa đăng nhập", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text("Đăng nhập để xem thông tin cá nhân", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.to(() => const LoginPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text("Đăng nhập / Đăng ký", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Giao diện đã đăng nhập
  Widget _buildAuthenticatedView(AuthController controller, Color primaryColor) {
    final user = controller.currentUser!;

    return RefreshIndicator(
      onRefresh: () => controller.refreshProfile(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER CHỨA ẢNH ĐẠI DIỆN VÀ TÊN
            Container(
              color: primaryColor,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                    child: user.avatarUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: Text("Đồng", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  )
                ],
              ),
            ),

            // 2. KHỐI ĐIỂM SỐ & THÀNH TÍCH
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("Điểm hiện tại", "${user.currentPoints}", Colors.orange),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildStatItem("Tổng tích lũy", "${user.totalPoints}", Colors.green),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. KHỐI THÔNG TIN CÁ NHÂN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Thông tin liên hệ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () => _showUpdateProfileDialog(controller, user, primaryColor),
                            child: Text("Chỉnh sửa", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _buildInfoRow(Icons.email_outlined, "Email", user.email),
                    const Divider(height: 1),
                    _buildInfoRow(Icons.phone_outlined, "Số điện thoại", user.phoneNumber.isNotEmpty ? user.phoneNumber : "Chưa cập nhật"),
                    const Divider(height: 1),
                    _buildInfoRow(Icons.location_on_outlined, "Địa chỉ", user.address.isNotEmpty ? user.address : "Chưa cập nhật"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. DANH SÁCH MENU CHỨC NĂNG
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildMenuTile(Icons.shopping_bag_outlined, Colors.blue, 'Lịch sử mua hàng', () {
                      Get.to(() => const OrderHistoryPage(), transition: Transition.cupertino, duration: const Duration(milliseconds: 400));
                    }),
                    const Divider(height: 1, indent: 50),
                    _buildMenuTile(Icons.lock_outline, Colors.orange, 'Đổi mật khẩu', () {
                      _showChangePasswordDialog(controller, primaryColor);
                    }),
                    const Divider(height: 1, indent: 50),
                    _buildMenuTile(Icons.logout, Colors.grey, 'Đăng xuất', () {
                      controller.logout();
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, Color iconColor, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  // --- Các Dialogs ---
  void _showUpdateProfileDialog(AuthController controller, UserInfo user, Color primaryColor) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);
    final addressCtrl = TextEditingController(text: user.address);

    Get.defaultDialog(
      title: "Cập nhật thông tin",
      titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      content: Column(
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Họ và Tên", prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: addressCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: "Địa chỉ nhận hàng", prefixIcon: Icon(Icons.location_on_outlined)),
          ),
        ],
      ),
      confirm: GetBuilder<AuthController>(
        id: 'profile_update',
        builder: (ctrl) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ElevatedButton(
            onPressed: ctrl.isLoading ? null : () {
              // Khởi tạo đối tượng UserInfo mới với các trường vừa sửa
              UserInfo updatedUser = UserInfo(
                id: user.id,
                email: user.email, // Không cho sửa email
                avatarUrl: user.avatarUrl,
                rank: user.rank,
                currentPoints: user.currentPoints,
                totalPoints: user.totalPoints,
                fullName: nameCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim(),
                address: addressCtrl.text.trim(),
              );
              ctrl.updateProfile(updatedUser);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(120, 40)),
            child: ctrl.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white)) : const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      cancel: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextButton(onPressed: () => Get.back(), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
      ),
    );
  }

  void _showChangePasswordDialog(AuthController controller, Color primaryColor) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    Get.defaultDialog(
      title: "Đổi mật khẩu",
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      content: Column(
        children: [
          TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu cũ")),
          TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu mới")),
          TextField(controller: confirmPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Xác nhận mật khẩu mới")),
        ],
      ),
      confirm: GetBuilder<AuthController>(
        id: 'password_update',
        builder: (ctrl) => ElevatedButton(
          onPressed: ctrl.isLoading ? null : () => ctrl.changePassword(oldPassCtrl.text, newPassCtrl.text, confirmPassCtrl.text),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: ctrl.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white)) : const Text("Xác nhận", style: TextStyle(color: Colors.white)),
        ),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
    );
  }
}