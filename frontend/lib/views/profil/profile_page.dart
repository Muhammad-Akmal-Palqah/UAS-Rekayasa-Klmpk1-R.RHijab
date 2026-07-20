import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../service/api_service.dart';
import '../../service/auth_service.dart';
import '../beranda/home_view.dart';
import '../favorit/favorit_page.dart';
import '../keranjang/cart_page.dart';
import '../keranjang/shipping_address_page.dart';
import '../shared/app_bottom_nav.dart';
import '../shop/catalog_view.dart';
import '../login_view.dart';
import 'profile_constants.dart';
import 'profile_info_view.dart';
import 'profile_header.dart';
import 'profile_menu_tile.dart';
import 'about_app_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
  late Future<List<Order>> _ordersFuture = ApiService.fetchUserOrders();

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = ApiService.fetchUserOrders();
    });
    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    FutureBuilder<List<Order>>(
                      future: _ordersFuture,
                      builder: (context, snapshot) {
                        final orderCount = snapshot.data?.length ?? 0;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FavoritPage(),
                              ),
                            );
                          },
                          child: _buildStatCard(
                            title: 'Pesanan',
                            value: orderCount.toString(),
                            icon: Icons.shopping_bag_outlined,
                            color: ProfileColors.dominant,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pengaturan akun',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ProfileColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ProfileMenuTile(
                            icon: Icons.person_outline,
                            title: 'Informasi pribadi',
                            subtitle: 'Lihat detail akun dan edit jika perlu',
                            color: ProfileColors.dominant,
                            onTap: () {
                              final navigator = Navigator.of(context);
                              navigator
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => const ProfileInfoPage(),
                                    ),
                                  )
                                  .then((_) {
                                    if (!mounted) return;
                                    setState(() {});
                                  });
                            },
                          ),
                          const SizedBox(height: 10),
                          ProfileMenuTile(
                            icon: Icons.location_on_outlined,
                            title: 'Alamat pengiriman',
                            subtitle: 'Atur alamat favoritmu',
                            color: ProfileColors.accentGreen,
                            onTap: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final selected = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ShippingAddressPage(),
                                ),
                              );

                              if (!mounted) return;
                              if (selected != null) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Alamat tersimpan'),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          ProfileMenuTile(
                            icon: Icons.info_outline,
                            title: 'Tentang aplikasi',
                            subtitle: 'Lihat info aplikasi dan versi',
                            color: ProfileColors.accentBlue,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AboutAppPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          ProfileMenuTile(
                            icon: Icons.logout,
                            title: 'Keluar',
                            subtitle: 'Akhiri sesi akun Anda',
                            color: ProfileColors.accentGreen,
                            onTap: () async {
                              if (!mounted) return;
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              await AuthService.signOut();
                              if (!mounted) return;

                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Logout berhasil'),
                                ),
                              );
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const LoginView(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 4) {
            setState(() {
              _selectedIndex = index;
            });
            return;
          }

          final destination = <Widget>[
            const HomeView(),
            const CatalogView(),
            const CartPage(),
            const FavoritPage(),
            const ProfilePage(),
          ][index];

          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ProfileColors.textDark, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ProfileColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: ProfileColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
