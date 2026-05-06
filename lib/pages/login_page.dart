import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final primaryColor = Colors.lightBlueAccent[200]!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo hoặc Tiêu đề
              Icon(Icons.menu_book_rounded, size: 80, color: primaryColor),
              const SizedBox(height: 16),
              const Text("Chào mừng trở lại!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                tabs: const [
                  Tab(text: "Người dùng"),
                  Tab(text: "Quản lý"),
                ],
              ),

              // Nội dung Tabs
              Expanded(
                child: TabBarView(
                  children: [
                    _buildUserLoginForm(controller, primaryColor),
                    _buildAdminLoginForm(primaryColor), // Sẽ code sau
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserLoginForm(AuthController controller, Color primaryColor) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            GetBuilder<AuthController>(
              id: 'password_toggle',
              builder: (ctrl) => TextField(
                controller: passCtrl,
                obscureText: ctrl.isPasswordHidden,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(ctrl.isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                    onPressed: ctrl.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GetBuilder<AuthController>(
              id: 'auth_button',
              builder: (ctrl) => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading ? null : () => ctrl.loginUser(emailCtrl.text, passCtrl.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: ctrl.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Đăng nhập", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có tài khoản?"),
                TextButton(
                  onPressed: () => Get.to(() => const RegisterPage()),
                  child: Text("Đăng ký ngay", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLoginForm(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("Cổng đăng nhập Quản lý\n(Đang phát triển)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}