import 'package:iam/core/constant/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/brands_cubit.dart';
import '../cubit/products_cubit.dart';
import '../cubit/offers_cubit.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import '../widgets/home_header.dart';
import '../widgets/categories_section.dart';
import '../widgets/brands_section.dart';
import '../widgets/offers_slider.dart';
import '../widgets/products_section.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<int>? refreshTrigger;

  const HomeScreen({super.key, this.refreshTrigger});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  int _refreshSeed = 0;
  DateTime? _lastRefreshTime;
  static const _minRefreshInterval = Duration(seconds: 2);
  static const _cacheDuration = Duration(minutes: 5);
  bool _hasInitialized = false;
  BuildContext? _providersContext;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attachRefreshListener();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _detachRefreshListener(oldWidget.refreshTrigger);
      _attachRefreshListener();
    }
  }

  @override
  void dispose() {
    _detachRefreshListener(widget.refreshTrigger);
    WidgetsBinding.instance.removeObserver(this);
    _providersContext = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final now = DateTime.now();
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!) > _cacheDuration) {
        _refreshData(forceRefresh: false);
      }
    }
  }

  void _attachRefreshListener() {
    widget.refreshTrigger?.addListener(_handleRefreshRequest);
  }

  void _detachRefreshListener(ValueNotifier<int>? notifier) {
    notifier?.removeListener(_handleRefreshRequest);
  }

  void _handleRefreshRequest() {
    if (!mounted) return;
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < _minRefreshInterval) {
      return;
    }
    _refreshData(forceRefresh: true);
  }

  Future<void> _refreshData({required bool forceRefresh}) async {
    if (!mounted) return;

    // Prevent rapid successive calls
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < _minRefreshInterval) {
      return;
    }

    final context = _providersContext;
    if (context == null || !context.mounted) return;

    try {
      final storageService = di.sl<StorageService>();
      final token = storageService.getToken();
      final hasToken = token != null && token.isNotEmpty;

      // Check cache validity
      final isCacheValid =
          _lastRefreshTime != null &&
          now.difference(_lastRefreshTime!) < _cacheDuration;

      // Load all data in parallel if cache is invalid or force refresh
      if (forceRefresh || !isCacheValid || !_hasInitialized) {
        final futures = <Future>[];

        // Load critical data in parallel
        final offersCubit = context.read<OffersCubit>();
        final categoriesCubit = context.read<CategoriesCubit>();
        final brandsCubit = context.read<BrandsCubit>();

        // Check if we need to reload based on state
        final offersState = offersCubit.state;
        final categoriesState = categoriesCubit.state;
        final brandsState = brandsCubit.state;

        if (forceRefresh || offersState is! OffersSuccess || !isCacheValid) {
          futures.add(offersCubit.getOffers());
        }

        if (forceRefresh ||
            categoriesState is! CategoriesSuccess ||
            !isCacheValid) {
          futures.add(categoriesCubit.getCategories());
        }

        if (forceRefresh || brandsState is! BrandsSuccess || !isCacheValid) {
          futures.add(brandsCubit.getBrands());
        }

        // Load favorites if authenticated
        if (hasToken) {
          final favoritesCubit = context.read<FavoritesCubit>();
          final favoritesState = favoritesCubit.state;
          if (forceRefresh ||
              favoritesState is! FavoritesSuccess ||
              !isCacheValid) {
            futures.add(favoritesCubit.getFavorites());
          }
        }

        // Load all in parallel - this is much faster than sequential
        if (futures.isNotEmpty) {
          await Future.wait(futures, eagerError: false);
        }

        if (mounted) {
          _lastRefreshTime = DateTime.now();
          _hasInitialized = true;
          if (forceRefresh) {
            setState(() {
              _refreshSeed++;
            });
          }
        }
      }
    } catch (e) {
      // Silently handle errors - let BlocBuilder handle UI state
      debugPrint('Error refreshing home data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<CategoriesCubit>()),
        BlocProvider(create: (context) => di.sl<BrandsCubit>()),
        BlocProvider(create: (context) => di.sl<OffersCubit>()),
        BlocProvider(create: (context) => di.sl<FavoritesCubit>()),
      ],
      child: Builder(
        builder: (ctx) {
          // Store providers context
          _providersContext = ctx;

          if (!_hasInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _refreshData(forceRefresh: false);
            });
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBody: true,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _refreshData(forceRefresh: true),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: RepaintBoundary(child: const HomeHeader()),
                    ),
                    // Offers - loads immediately, shows as soon as ready
                    SliverToBoxAdapter(
                      child: RepaintBoundary(child: const OffersSlider()),
                    ),
                    // Categories - loads immediately, shows as soon as ready
                    SliverToBoxAdapter(
                      child: RepaintBoundary(child: const CategoriesSection()),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                    // Brands - loads immediately, shows as soon as ready
                    SliverToBoxAdapter(
                      child: RepaintBoundary(child: const BrandsSection()),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                    // All Products - lazy loaded
                    SliverToBoxAdapter(
                      child: _LazyProductsSection(
                        key: ValueKey('all_products_section_$_refreshSeed'),
                        refreshSeed: _refreshSeed,
                        title: AppTexts.allProducts,
                        isBestProducts: false,
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                    // Best Products - lazy loaded
                    SliverToBoxAdapter(
                      child: _LazyProductsSection(
                        key: ValueKey('best_products_section_$_refreshSeed'),
                        refreshSeed: _refreshSeed,
                        title: AppTexts.bestProducts,
                        isBestProducts: true,
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Lazy-loaded products section with optimized loading
class _LazyProductsSection extends StatefulWidget {
  final int refreshSeed;
  final String title;
  final bool isBestProducts;

  const _LazyProductsSection({
    super.key,
    required this.refreshSeed,
    required this.title,
    required this.isBestProducts,
  });

  @override
  State<_LazyProductsSection> createState() => _LazyProductsSectionState();
}

class _LazyProductsSectionState extends State<_LazyProductsSection>
    with AutomaticKeepAliveClientMixin {
  bool _hasLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load after a short delay to prioritize above-the-fold content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _hasLoaded = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_hasLoaded) {
      return SizedBox(
        height: 330.h,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: BlocProvider(
        key: ValueKey(
          '${widget.isBestProducts ? "best" : "all"}_products_provider_${widget.refreshSeed}',
        ),
        create: (context) => di.sl<ProductsCubit>(),
        child: ProductsSection(
          key: ValueKey(
            '${widget.isBestProducts ? "best" : "all"}_products_section_${widget.refreshSeed}',
          ),
          title: widget.title,
          isBestProducts: widget.isBestProducts,
        ),
      ),
    );
  }
}
