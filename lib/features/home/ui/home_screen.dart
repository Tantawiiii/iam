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
  bool _hasRefreshedProducts = false;
  bool _isInitialLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  BuildContext? _providersContext;
  DateTime? _lastRefreshTime;
  static const _minRefreshInterval = Duration(seconds: 2);
  static const _cacheDuration = Duration(minutes: 5); // Cache for 5 minutes
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attachRefreshListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshHomeData(showLoading: true, forceRefresh: false);
      }
    });
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
  bool get wantKeepAlive => true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Only refresh if cache is stale (more than cache duration)
      final now = DateTime.now();
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!) > _cacheDuration) {
        _refreshHomeData(showLoading: false, forceRefresh: false);
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
    if (!mounted || _isRefreshing) return;
    // Debounce rapid refresh requests
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < _minRefreshInterval) {
      return;
    }
    _refreshHomeData(showLoading: false, forceRefresh: false);
  }

  /// Check if data is cached and still valid
  bool _isDataCached(BuildContext context) {
    final offersState = context.read<OffersCubit>().state;
    final categoriesState = context.read<CategoriesCubit>().state;
    final brandsState = context.read<BrandsCubit>().state;

    final hasCachedOffers = offersState is OffersSuccess;
    final hasCachedCategories = categoriesState is CategoriesSuccess;
    final hasCachedBrands = brandsState is BrandsSuccess;

    return hasCachedOffers && hasCachedCategories && hasCachedBrands;
  }

  /// Check if cache is still valid (not expired)
  bool _isCacheValid() {
    if (_lastRefreshTime == null) return false;
    final now = DateTime.now();
    return now.difference(_lastRefreshTime!) < _cacheDuration;
  }

  Future<void> _refreshHomeData({
    bool showLoading = false,
    bool forceRefresh = false,
  }) async {
    final providersContext = _providersContext;
    if (providersContext == null || _isRefreshing) {
      return;
    }

    // Check if we have cached data and it's still valid
    if (!forceRefresh && _isDataCached(providersContext) && _isCacheValid()) {
      // Use cached data, no need to make API calls
      if (mounted && _isInitialLoading) {
        setState(() {
          _isInitialLoading = false;
          _hasError = false;
          _errorMessage = null;
        });
      }
      return;
    }

    // Prevent rapid successive calls
    final now = DateTime.now();
    if (!showLoading &&
        !forceRefresh &&
        _lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < _minRefreshInterval) {
      return;
    }

    _isRefreshing = true;

    if (showLoading && mounted) {
      setState(() {
        _isInitialLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      final storageService = di.sl<StorageService>();
      final token = storageService.getToken();
      final hasToken = token != null && token.isNotEmpty;

      // Check which data needs to be refreshed
      final offersState = providersContext.read<OffersCubit>().state;
      final categoriesState = providersContext.read<CategoriesCubit>().state;
      final brandsState = providersContext.read<BrandsCubit>().state;

      // Prioritize critical data - only load if not cached or cache expired
      final criticalFutures = <Future>[];

      if (forceRefresh || !(offersState is OffersSuccess && _isCacheValid())) {
        criticalFutures.add(providersContext.read<OffersCubit>().getOffers());
      }

      if (forceRefresh ||
          !(categoriesState is CategoriesSuccess && _isCacheValid())) {
        criticalFutures.add(
          providersContext.read<CategoriesCubit>().getCategories(),
        );
      }

      // Load critical data first (only if needed)
      if (criticalFutures.isNotEmpty) {
        await Future.wait(criticalFutures);
      }

      // Then load secondary data in parallel (only if needed)
      final secondaryFutures = <Future>[];

      if (forceRefresh || !(brandsState is BrandsSuccess && _isCacheValid())) {
        secondaryFutures.add(providersContext.read<BrandsCubit>().getBrands());
      }

      // Only call getFavorites if user is authenticated
      if (hasToken) {
        final favoritesState = providersContext.read<FavoritesCubit>().state;
        if (forceRefresh ||
            !(favoritesState is FavoritesSuccess && _isCacheValid())) {
          secondaryFutures.add(
            providersContext.read<FavoritesCubit>().getFavorites(),
          );
        }
      }

      if (secondaryFutures.isNotEmpty) {
        await Future.wait(secondaryFutures);
      }

      if (!mounted) {
        _isRefreshing = false;
        return;
      }

      // Update cache timestamp only if we actually fetched data
      if (criticalFutures.isNotEmpty || secondaryFutures.isNotEmpty) {
        _lastRefreshTime = DateTime.now();
      }

      // Combine all setState calls into one
      setState(() {
        _isInitialLoading = false;
        _hasError = false;
        _errorMessage = null;
        if (_hasRefreshedProducts) {
          _refreshSeed++;
        } else {
          _hasRefreshedProducts = true;
        }
      });
    } catch (e) {
      if (!mounted) {
        _isRefreshing = false;
        return;
      }
      setState(() {
        _isInitialLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<CategoriesCubit>()),
        BlocProvider(create: (context) => di.sl<BrandsCubit>()),
        BlocProvider(create: (context) => di.sl<OffersCubit>()),
        BlocProvider(create: (context) => di.sl<FavoritesCubit>()),
      ],
      child: Builder(
        builder: (ctx) {
          _providersContext = ctx;

          // Show initial loading state
          if (_isInitialLoading) {
            return const _LoadingScreen();
          }

          // Show error state
          if (_hasError) {
            return _ErrorScreen(
              errorMessage: _errorMessage,
              onRetry: () =>
                  _refreshHomeData(showLoading: true, forceRefresh: true),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBody: true,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _refreshHomeData(
                        showLoading: false,
                        forceRefresh: true,
                      ),
                      child: _AnimatedContent(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RepaintBoundary(child: const HomeHeader()),
                              RepaintBoundary(child: const OffersSlider()),
                              RepaintBoundary(child: const CategoriesSection()),
                              SizedBox(height: 20.h),
                              RepaintBoundary(child: const BrandsSection()),
                              SizedBox(height: 28.h),
                              _LazyProductsSection(
                                key: ValueKey(
                                  'all_products_section_$_refreshSeed',
                                ),
                                refreshSeed: _refreshSeed,
                                title: AppTexts.allProducts,
                                isBestProducts: false,
                              ),
                              SizedBox(height: 28.h),
                              _LazyProductsSection(
                                key: ValueKey(
                                  'best_products_section_$_refreshSeed',
                                ),
                                refreshSeed: _refreshSeed,
                                title: AppTexts.bestProducts,
                                isBestProducts: true,
                              ),
                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedContent extends StatefulWidget {
  final Widget child;

  const _AnimatedContent({required this.child});

  @override
  State<_AnimatedContent> createState() => _AnimatedContentState();
}

class _AnimatedContentState extends State<_AnimatedContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}

/// Lazy-loaded products section that only loads when visible
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
    // Delay loading to prioritize critical sections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
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

/// Optimized loading screen widget
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              SizedBox(height: 24.h),
              Text(
                AppTexts.home,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optimized error screen widget
class _ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const _ErrorScreen({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                SizedBox(height: 24.h),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  errorMessage ?? 'Please check your connection and try again',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text(AppTexts.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
