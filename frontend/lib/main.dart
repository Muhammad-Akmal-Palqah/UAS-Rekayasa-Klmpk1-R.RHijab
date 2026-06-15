import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'models/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByZaine Hijab Shop',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xffffcccc),
        scaffoldBackgroundColor: const Color(0xfffff4f4),
        cardColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(fontSize: 15, color: Colors.black87),
          bodySmall: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffccccff),
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserAuth? _currentUser;
  int _selectedIndex = 0;
  final Set<String> _favoriteIds = productCatalog
      .where((product) => product.isFavorite)
      .map((product) => product.id)
      .toSet();

  List<Product> get _favoriteProducts => productCatalog
      .where((product) => _favoriteIds.contains(product.id))
      .toList();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFavorite(String productId) {
    setState(() {
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });
  }

  Future<void> _signIn({
    required String email,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    final user = await AuthService.signIn(
      email: email,
      username: username,
      password: password,
      role: role,
    );

    setState(() {
      _currentUser = user;
      _selectedIndex = 0;
    });
  }

  void _signOut() {
    setState(() {
      _currentUser = null;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return LoginPage(onSignIn: _signIn);
    }

    final currentUser = _currentUser!;
    final pages = <Widget>[
      LandingPage(favoriteIds: _favoriteIds, onToggleFavorite: _toggleFavorite),
      ShopPage(favoriteIds: _favoriteIds, onToggleFavorite: _toggleFavorite),
      FavoritesPage(
        favoriteProducts: _favoriteProducts,
        onToggleFavorite: _toggleFavorite,
      ),
      AccountPage(
        isSignedIn: true,
        accountName: currentUser.username,
        accountEmail: currentUser.email,
        accountRole: getRoleLabel(currentUser.role),
        onSignOut: _signOut,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black45,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<String> onToggleFavorite;

  const LandingPage({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(),
          const SizedBox(height: 18),
          const _HeroCard(),
          const SizedBox(height: 16),
          const _FeatureHighlights(),
          const SizedBox(height: 22),
          const _SectionHeader(
            title: 'Our bestsellers',
            subtitle: 'Discover top picks loved by customers.',
          ),
          const SizedBox(height: 20),
          _BestSellerCarousel(
            favoriteIds: favoriteIds,
            onToggleFavorite: onToggleFavorite,
          ),
          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Eco-friendly hijabs',
            subtitle: 'Premium modal fabrics for your style.',
          ),
          const SizedBox(height: 20),
          _ProductGrid(
            favoriteIds: favoriteIds,
            onToggleFavorite: onToggleFavorite,
          ),
          const SizedBox(height: 24),
          const _ContactPanel(),
          const SizedBox(height: 24),
          const _FooterPanel(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ShopPage extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<String> onToggleFavorite;

  const ShopPage({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Check our eco-friendly hijabs',
            subtitle:
                'Sustainable fabrics like premium modal, acrylic, and viscose that care for your hijab and our planet.',
          ),
          const SizedBox(height: 18),
          const _SearchBar(),
          const SizedBox(height: 20),
          _ShopGrid(
            favoriteIds: favoriteIds,
            onToggleFavorite: onToggleFavorite,
          ),
          const SizedBox(height: 24),
          const _ShopFooterCTA(),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Product> favoriteProducts;
  final ValueChanged<String> onToggleFavorite;

  const FavoritesPage({
    super.key,
    required this.favoriteProducts,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite, size: 30, color: Color(0xffffcccc)),
              SizedBox(width: 12),
              Text(
                'Favorites',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'You have ${favoriteProducts.length} favorite items.',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Column(
            children: favoriteProducts
                .map(
                  (product) => _FavoriteCard(
                    product: product,
                    isFavorite: true,
                    onToggleFavorite: onToggleFavorite,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xffccccff),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Favorites Tip',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap a hijab card to see more details or add it to your cart.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  final bool isSignedIn;
  final String accountName;
  final String accountEmail;
  final String accountRole;
  final VoidCallback onSignOut;

  const AccountPage({
    super.key,
    required this.isSignedIn,
    required this.accountName,
    required this.accountEmail,
    required this.accountRole,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = accountName.isNotEmpty ? accountName : 'Guest User';
    final displayEmail = accountEmail.isNotEmpty ? accountEmail : 'No email available';
    final displayRole = isSignedIn ? accountRole : 'Guest';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffffcccc),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayRole,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffffcccc),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.favorite, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '3 Saved',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xffccffcc),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.mail_outline, color: Colors.black87),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayEmail,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: Colors.black87),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayRole,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  children: const [
                    SizedBox(width: 100, child: _AccountStat(label: 'Orders', value: '14')),
                    SizedBox(width: 100, child: _AccountStat(label: 'Wishlist', value: '3')),
                    SizedBox(width: 100, child: _AccountStat(label: 'Rewards', value: '45')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Account Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const _AccountMenuItem(
            icon: Icons.shopping_bag_outlined,
            label: 'My Orders',
          ),
          const _AccountMenuItem(
            icon: Icons.favorite,
            label: 'Saved Items',
            iconColor: Color(0xffff6666),
          ),
          const _AccountMenuItem(
            icon: Icons.settings_outlined,
            label: 'Preferences',
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffffcccc),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStat extends StatelessWidget {
  final String label;
  final String value;

  const _AccountStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _AccountMenuItem({
    required this.icon,
    required this.label,
    this.iconColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffffcccc),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.menu, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'ByZaine',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffccccff),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: Colors.black87,
                  ),
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xffffcccc),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffffcccc),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'MODEST. MODERN. YOU.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final imageWidth = isWide ? 130.0 : 110.0;
        final imageHeight = isWide ? 200.0 : 170.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffffcccc),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elevating modesty and empowering the hijab',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 14),
              const Text(
                'Wear it like you own your art.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  SizedBox(
                    width: isWide
                        ? constraints.maxWidth * 0.55
                        : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _BadgeLine(
                          icon: Icons.diamond_outlined,
                          label: 'Premium Quality',
                        ),
                        SizedBox(height: 14),
                        _BadgeLine(
                          icon: Icons.eco_outlined,
                          label: 'Sustainable Choice',
                        ),
                        const SizedBox(height: 10),
                        _BadgeLine(
                          icon: Icons.location_on_outlined,
                          label: 'Made with Love in Amsterdam',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xffccccff),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 70, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShopPage(
                        favoriteIds: <String>{},
                        onToggleFavorite: (_) {},
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffccccff),
                  foregroundColor: Colors.black87,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Text(
                    'SHOP NOW',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BadgeLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _FeatureHighlights extends StatelessWidget {
  const _FeatureHighlights();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final maxCardWidth = 220.0;
        final minCardWidth = 150.0;
        final cardWidth = ((constraints.maxWidth - spacing * 2) / 3).clamp(
          minCardWidth,
          maxCardWidth,
        );

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            SizedBox(
              width: cardWidth,
              child: const _SmallFeatureCard(
                icon: Icons.verified,
                title: 'Comfort',
                subtitle: 'Luxury fabrics',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _SmallFeatureCard(
                icon: Icons.eco_outlined,
                title: 'Eco-friendly',
                subtitle: 'Eco-friendly materials',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _SmallFeatureCard(
                icon: Icons.favorite_border,
                title: 'Quality',
                subtitle: 'Made with love',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmallFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SmallFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffccffcc),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: Colors.black87),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _BestSellerCarousel extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<String> onToggleFavorite;

  const _BestSellerCarousel({
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final items = productCatalog.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalSpacing = 12.0;
        const minCardWidth = 180.0;
        const maxCardWidth = 320.0;
        final availableWidth = constraints.maxWidth;
        final isWide = availableWidth >= 980;
        final itemWidth = isWide
            ? ((availableWidth - horizontalSpacing * 2) / 3)
                .clamp(minCardWidth, maxCardWidth)
            : availableWidth > 720
                ? ((availableWidth - horizontalSpacing) / 2)
                    .clamp(minCardWidth, maxCardWidth)
                : availableWidth * 0.85;
        final itemHeight = itemWidth * 1.05 + 70;

        if (isWide) {
          return SizedBox(
            height: itemHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (product) => SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: _ProductTile(
                        product: product,
                        isFavorite: favoriteIds.contains(product.id),
                        onToggleFavorite: onToggleFavorite,
                      ),
                    ),
                  )
                  .expand((widget) => [widget, const SizedBox(width: horizontalSpacing)])
                  .toList()
                ..removeLast(),
            ),
          );
        }

        return SizedBox(
          height: itemHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: horizontalSpacing),
            itemBuilder: (context, index) {
              final product = items[index];
              return SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _ProductTile(
                  product: product,
                  isFavorite: favoriteIds.contains(product.id),
                  onToggleFavorite: onToggleFavorite,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: horizontalSpacing),
            itemCount: items.length,
          ),
        );
      },
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<String> onToggleFavorite;

  const _ProductGrid({
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final items = productCatalog
        .where((product) => product.badge != null)
        .take(4)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalSpacing = 12.0;
        const minCardWidth = 180.0;
        const maxCardWidth = 320.0;
        final availableWidth = constraints.maxWidth;
        final crossAxisCount =
            ((availableWidth + horizontalSpacing) /
                    (minCardWidth + horizontalSpacing))
                .toInt();
        final effectiveCrossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;
        final itemWidth =
            (availableWidth -
                horizontalSpacing * (effectiveCrossAxisCount - 1)) /
            effectiveCrossAxisCount;
        final cardWidth = itemWidth.clamp(minCardWidth, maxCardWidth);
        final cardHeight = cardWidth * 1.05 + 80;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: horizontalSpacing,
              runSpacing: 16,
              children: items
                  .map(
                    (product) => SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _ProductTile(
                        product: product,
                        isFavorite: favoriteIds.contains(product.id),
                        onToggleFavorite: onToggleFavorite,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${items.length} popular styles ready to shop',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShopGrid extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<String> onToggleFavorite;

  const _ShopGrid({required this.favoriteIds, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final items = productCatalog;

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalSpacing = 12.0;
        const minCardWidth = 220.0;
        const maxCardWidth = 320.0;
        final availableWidth = constraints.maxWidth;
        final crossAxisCount =
            ((availableWidth + horizontalSpacing) ~/
                    (minCardWidth + horizontalSpacing))
                .toInt();
        final effectiveCrossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;
        final itemWidth =
            (availableWidth -
                horizontalSpacing * (effectiveCrossAxisCount - 1)) /
            effectiveCrossAxisCount;
        final cardWidth = itemWidth.clamp(180.0, maxCardWidth);
        final cardHeight = cardWidth * 1.05 + 80;

        return Wrap(
          spacing: horizontalSpacing,
          runSpacing: 12,
          children: items
              .map(
                (product) => SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _ProductTile(
                    product: product,
                    isFavorite: favoriteIds.contains(product.id),
                    onToggleFavorite: onToggleFavorite,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.black45),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cari hijab pilihan...',
              style: TextStyle(color: Colors.black45, fontSize: 15),
            ),
          ),
          Icon(Icons.filter_list, color: Colors.black45),
        ],
      ),
    );
  }
}

class _ShopFooterCTA extends StatelessWidget {
  const _ShopFooterCTA();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xffccccff),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Shop eco collection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.black87),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final ValueChanged<String> onToggleFavorite;

  const _ProductTile({
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              product: product,
              isFavorite: isFavorite,
              onToggleFavorite: onToggleFavorite,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: product.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (product.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      product.badge!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onToggleFavorite(product.id),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey<bool>(isFavorite),
                        size: 20,
                        color: isFavorite ? Colors.redAccent : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(102),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 52, color: Colors.white70),
                ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = (constraints.maxWidth * 0.45).clamp(90.0, 120.0);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 52, color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              product.price,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                product.rating,
                (index) =>
                    const Icon(Icons.star, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final ValueChanged<String> onToggleFavorite;

  const _FavoriteCard({
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailsPage(
                  product: product,
                  isFavorite: isFavorite,
                  onToggleFavorite: onToggleFavorite,
                ),
              ),
            );
          },
          child: LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = (constraints.maxWidth * 0.28).clamp(84.0, 110.0);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: product.color,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 56, color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(
                            product.rating,
                            (index) => const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onToggleFavorite(product.id),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey<bool>(isFavorite),
                        color: isFavorite ? Colors.redAccent : Colors.black38,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final ValueChanged<String> onToggleFavorite;

  const ProductDetailsPage({
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: const Color(0xffffcccc),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: product.color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 24,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onToggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey<bool>(isFavorite),
                          color: isFavorite ? Colors.redAccent : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  child: Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(89),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 120,
                          color: Colors.white70,
                        ),
                      ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final imageSize = (constraints.maxWidth * 0.65).clamp(160.0, 220.0);
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 120,
                              color: Colors.white70,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.price,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffffcccc),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${product.rating}.0',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Product Description',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(product.description),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xffccffcc),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Material: Premium modal fabric\nCare: Handwash recommended\nSize: One size fits most',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffffcccc),
                            foregroundColor: Colors.black87,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.share, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactPanel extends StatelessWidget {
  const _ContactPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xffccffcc),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'We’re here to help',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Have a question about our products or your order? Our team is ready to assist you.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 18),
              _ContactRow(
                icon: Icons.flash_on_outlined,
                label: 'Fast Response',
              ),
              SizedBox(height: 10),
              _ContactRow(icon: Icons.support_agent, label: 'Customer Care'),
              SizedBox(height: 10),
              _ContactRow(icon: Icons.thumb_up_off_alt, label: 'Satisfaction'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xffffcccc),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Leave Us Message For Any Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              _ContactField(label: 'Your name'),
              _ContactField(label: 'Email address'),
              _ContactField(label: 'Order number (optional)'),
              _ContactField(label: 'Your message', maxLines: 4),
              SizedBox(height: 10),
              _SendButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  final String label;
  final int maxLines;

  const _ContactField({required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      child: const Text(
        'Send us a message',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FooterPanel extends StatelessWidget {
  const _FooterPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About ByZaine',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text('Links', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          Row(
            children: const [
              Icon(Icons.facebook, size: 24),
              SizedBox(width: 14),
              Icon(Icons.favorite, size: 24),
              SizedBox(width: 14),
              Icon(Icons.music_note, size: 24),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Stay in the loop',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xfffff1f1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Your email address',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '© 2024 ByZaine.com',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

