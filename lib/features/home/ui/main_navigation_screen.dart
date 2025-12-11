import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../ui/home_screen.dart';
import '../../cart/ui/cart_screen.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../favorites/ui/wishlist_screen.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import '../ui/search_screen.dart';
import '../cubit/search_cubit.dart';
import '../../settings/ui/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 2;
  final ValueNotifier<int> _homeRefreshNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _homeRefreshNotifier.dispose();
    super.dispose();
  }

  void _onNavItemTapped(BuildContext context, int index) {
    setState(() {
      _selectedIndex = index;
    });

    final storageService = di.sl<StorageService>();
    final token = storageService.getToken();
    final hasToken = token != null && token.isNotEmpty;

    if (index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && hasToken) {
          context.read<CartCubit>().getCart();
        }
      });
    } else if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && hasToken) {
          context.read<FavoritesCubit>().getFavorites();
        }
      });
    } else if (index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _homeRefreshNotifier.value++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<CartCubit>()),
        BlocProvider(create: (context) => di.sl<FavoritesCubit>()),
        BlocProvider(create: (context) => di.sl<SearchCubit>()),
      ],
      child: Builder(
        builder: (builderContext) {
          final screens = [
            _buildWishlistScreen(),
            _buildCartScreen(),
            _buildHomeScreen(),
            _buildSearchScreen(),
            _buildSettingsScreen(),
          ];

          return Scaffold(
            backgroundColor: AppColors.background,
            resizeToAvoidBottomInset: false,
            extendBody: true,

            body: IndexedStack(index: _selectedIndex, children: screens),
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) => _onNavItemTapped(builderContext, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen() {
    return HomeScreen(
      key: const ValueKey('home_screen'),
      refreshTrigger: _homeRefreshNotifier,
    );
  }

  Widget _buildCartScreen() {
    return const CartScreen(key: ValueKey('cart_screen'));
  }

  Widget _buildWishlistScreen() {
    return const WishlistScreen(key: ValueKey('wishlist_screen'));
  }

  Widget _buildSearchScreen() {
    return const SearchScreen(key: ValueKey('search_screen'));
  }

  Widget _buildSettingsScreen() {
    return const SettingsScreen(key: ValueKey('settings_screen'));
  }
}
