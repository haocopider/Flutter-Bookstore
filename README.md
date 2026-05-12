# 📚 Bookstore Mobile App (Flutter)

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.7.0-blue.svg)](https://flutter.dev/)
[![GetX](https://img.shields.io/badge/State%20Management-GetX-purple.svg)](https://pub.dev/packages/get)
[![Dependency Injection](https://img.shields.io/badge/DI-Get__It-orange.svg)](https://pub.dev/packages/get_it)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Bookstore** là một ứng dụng di động thương mại điện tử chuyên về sách, được xây dựng bằng Flutter. Ứng dụng cung cấp trải nghiệm mua sắm mượt mà từ việc khám phá các đầu sách mới, quản lý giỏ hàng đến quy trình thanh toán và theo dõi đơn hàng.

## ✨ Tính năng chính

* **🛒 Quản lý giỏ hàng:** Thêm, xóa và cập nhật số lượng sách trong giỏ hàng một cách nhanh chóng.
* **🔍 Tìm kiếm nâng cao:** Tìm kiếm sách theo tiêu đề, tác giả hoặc danh mục thông qua hệ thống lọc thông minh.
* **👤 Quản lý người dùng:** Đăng ký, đăng nhập và bảo mật thông tin bằng JWT Token lưu trữ qua `SharedPreferences`.
* **💳 Quy trình thanh toán:** Tích hợp quy trình đặt hàng, áp dụng mã khuyến mãi và xem lại lịch sử giao dịch.
* **🖼️ UI/UX hiện đại:** Sử dụng `Carousel Slider` cho các banner khuyến mãi và `Flutter Slidable` cho các thao tác nhanh (vuốt để xóa/sửa).
* **📦 Theo dõi đơn hàng:** Xem chi tiết trạng thái, danh sách sản phẩm đã mua và lịch sử đơn hàng cá nhân.
* **⭐ Đánh giá & Phản hồi:** Cho phép người dùng để lại đánh giá và nhận xét về các đầu sách đã đọc.

## 🏗️ Kiến trúc ứng dụng

Dự án tuân thủ các nguyên lý phát triển phần mềm sạch (Clean Architecture) với các tầng riêng biệt:

* **Controllers (GetX):** Quản lý logic nghiệp vụ và trạng thái (State Management) của ứng dụng một cách reactive.
* **Services:** Xử lý các tác vụ ngoại vi như gọi API (`ApiService`), Dependency Injection (`GetIt`), và lưu trữ cục bộ.
* **Models:** Định nghĩa cấu trúc dữ liệu và logic mapping (chuyển đổi JSON sang Object và ngược lại).
* **Pages/Components:** Tầng giao diện người dùng (UI) được tách nhỏ thành các widget có khả năng tái sử dụng cao.

## 🛠️ Công nghệ sử dụng

* **Framework:** Flutter (Dart)
* **State Management:** `GetX` - Quản lý trạng thái, định tuyến (Navigation) và Dependency Management.
* **Dependency Injection:** `Get_It` - Quản lý việc khởi tạo các dịch vụ toàn cục (Singletons).
* **Networking:** `HTTP` với tùy chỉnh `LoggingClient` để theo dõi các yêu cầu mạng trong quá trình phát triển.
* **Local Storage:** `Shared Preferences` - Lưu trữ dữ liệu phiên đăng nhập và cấu hình ứng dụng.
* **UI Components:** `Carousel Slider`, `Flutter Slidable`, `Cupertino Icons`.

## 📂 Cấu trúc thư mục

*lib/
*├── controllers/    # Quản lý Logic & State (Auth, Cart, Order, Book,...)
*├── helpers/        # Các hàm tiện ích (Permissions, Storage helper,...)
*├── models/         # Định nghĩa Data Models (Book, Author, Category, Review,...)
*├── pages/          # Giao diện chính & Các màn hình chức năng
*│   └── components/ # Các Widget con dùng chung (BookCard, OrderCard,...)
*├── services/       # API Service, DI Setup, Base Service, Logging
*└── main.dart       # Điểm khởi đầu của ứng dụng
