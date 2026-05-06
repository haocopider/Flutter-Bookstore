import 'package:bookstore/controllers/promotion_controller.dart';
import 'package:bookstore/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';
import 'author_detail_page.dart';
import 'components/carousel_slider.dart';
import '../pages/components/book_card.dart';
import 'book_detail_page.dart';
import 'cart_page.dart';
import 'category_book_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    Get.find<CartController>();
    final Color primaryColor = Colors.lightBlueAccent[200]!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: primaryColor,
                title: _buildAppBarTitle(),
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  tabs: [
                    Tab(text: "Sách"),
                    Tab(text: "Tác giả"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildBooksTab(homeController, primaryColor),
              _buildAuthorsTab(homeController, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const SearchPage()),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Tìm "tên sách" hoặc "#theloai"...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GetBuilder<CartController>(
            id: 'cart_badge',
            builder: (cartController) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () => Get.to(() => const CartPage()),
                  ),
                  if (cartController.cartMap.isNotEmpty)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        child: Text(
                          '${cartController.cartMap.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                ],
              );
            }
        ),
      ],
    );
  }

  Widget _buildBooksTab(HomeController homeController, Color primaryColor ) {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: homeController.fetchHomeData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. CAROUSEL SLIDER (BANNER)
          SliverToBoxAdapter(
            child: GetBuilder<PromotionController>(
              builder: (controller) {
                if (controller.events.isEmpty) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return PromotionCarousel(promotions: controller.events);
              },
            ),
          ),
          // PromotionCarousel(promotions: pController.events),

          // 2. DANH MỤC THỂ LOẠI (CATEGORIES)
          SliverToBoxAdapter(
            child: GetBuilder<HomeController>(
                id: 'categories_section',
                builder: (controller) {
                  if (controller.isCategoriesLoading) {
                    return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                  }
                  if (controller.categories.isEmpty) return const SizedBox.shrink();

                  final categoryList = controller.categories.values.toList();
                  return Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8, top: 8),
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        final category = categoryList[index];
                        return GestureDetector(
                          onTap: () => Get.to(() => CategoryBooksPage(categoryId: category.id, categoryName: category.name)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.menu_book, color: Colors.lightBlueAccent),
                                ),
                                const SizedBox(height: 4),
                                Text(category.name, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
            ),
          ),

          // 3. DANH SÁCH SẢN PHẨM
          SliverToBoxAdapter(
            child: GetBuilder<HomeController>(
              id: 'books_section',
              builder: (controller) {
                if (controller.isBooksLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: primaryColor)),
                  );
                }

                final promoList = controller.promoBooks.values.toList();
                final trendingList = controller.trendingBooks.values.toList();
                final allBooksList = controller.allBooks.values.toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KHU VỰC 1: SÁCH KHUYẾN MÃI
                    if (promoList.isNotEmpty) ...[
                      _buildSectionTitle("Siêu Sale Khuyến Mãi", Colors.redAccent),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: promoList.length,
                          itemBuilder: (context, index) => SizedBox(
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: BookCard(
                                  book: promoList[index],
                                  onTap: () => Get.to(() => BookDetailPage(bookId: promoList[index].id))
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // KHU VỰC 2: SÁCH BÁN CHẠY
                    if (trendingList.isNotEmpty) ...[
                      _buildSectionTitle("Sách Bán Chạy", primaryColor),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: trendingList.length,
                          itemBuilder: (context, index) => SizedBox(
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: BookCard(
                                  book: trendingList[index],
                                  onTap: () => Get.to(() => BookDetailPage(bookId: trendingList[index].id))
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // KHU VỰC 3: TOÀN BỘ SÁCH
                    if (allBooksList.isNotEmpty) ...[
                      _buildSectionTitle("Toàn Bộ Sách", primaryColor, showSeeAll: false),
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: allBooksList.length,
                        itemBuilder: (context, index) => BookCard(
                            book: allBooksList[index],
                            onTap: () => Get.to(() => BookDetailPage(bookId: allBooksList[index].id))
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  // TAB 2: GIAO DIỆN TÁC GIẢ
  Widget _buildAuthorsTab(HomeController homeController, Color primaryColor) {
    return Column(
      children: [
        // THANH TÌM KIẾM HIỆN ĐẠI
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              onChanged: homeController.searchAuthor,
              decoration: InputDecoration(
                hintText: "Tìm kiếm tên tác giả...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        // DANH SÁCH TÁC GIẢ
        Expanded(
          child: GetBuilder<HomeController>(
            id: 'authors_section',
            builder: (controller) {
              if (controller.isAuthorsLoading) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (controller.filteredAuthors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text("Không tìm thấy tác giả nào.", style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              final authorList = controller.filteredAuthors.values.toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: authorList.length,
                itemBuilder: (context, index) {
                  final author = authorList[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 28, // Tăng kích thước avatar một chút
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(
                              author.imageUrl ?? 'https://i.pinimg.com/originals/88/76/1a/88761a81450af688cd5386e36190dd02.jpg'
                          ),
                        ),
                        title: Text(
                            author.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            author.biography ?? "Đang cập nhật thông tin...",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_ios, color: primaryColor, size: 14),
                        ),
                        onTap: () {
                          Get.to(() => AuthorDetailPage(author: author));
                        }
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color, {bool showSeeAll = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (showSeeAll)
            Text("Xem tất cả", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}