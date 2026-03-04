import 'package:flutter/material.dart';

import '../../features/auth/ui/login_screen.dart';
import 'app_routes.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/cubit/public_setting_cubit.dart';
import 'package:iam/core/di/inject.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/ui/signup_screen.dart';
import '../../features/auth/ui/verify_otp_screen.dart';
import '../../features/home/ui/main_navigation_screen.dart';
import '../../features/home/ui/category_products_screen.dart';
import '../../features/home/ui/brand_products_screen.dart';
import '../../features/home/ui/product_details_screen.dart';
import '../../features/cart/ui/cart_screen.dart';
import '../../features/checkout/ui/checkout_screen.dart';
import '../../features/cart/models/cart_item_model.dart';
import '../../features/home/ui/all_products_screen.dart';
import '../../features/reviews/ui/add_review_screen.dart';
import '../../features/settings/cubit/user_info_cubit.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/settings/ui/user_info_screen.dart';
import '../../features/orders/ui/order_details_screen.dart';
import '../../features/checkout/ui/order_success_screen.dart';
import '../../features/checkout/models/create_order_data_model.dart';
import '../../features/auth/ui/terms_and_conditions_screen.dart';
import '../../features/auth/ui/forgot_password_screen.dart';
import '../../features/auth/ui/reset_password_screen.dart';
import '../../features/checkout/ui/payment_webview_screen.dart';

Route<dynamic> onGenerateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.onboarding:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => sl<PublicSettingCubit>(),
          child: const OnboardingScreen(),
        ),
      );
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.signup:
      return MaterialPageRoute(builder: (_) => const SignupScreen());
    case AppRoutes.verifyOtp:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => VerifyOtpScreen(
          email: args?['email'] as String? ?? '',
          isPasswordReset: args?['isPasswordReset'] as bool? ?? false,
        ),
      );
    case AppRoutes.forgotPassword:
      return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
    case AppRoutes.resetPassword:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) =>
            ResetPasswordScreen(email: args?['email'] as String? ?? ''),
      );
    case AppRoutes.home:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => MainNavigationScreen(
          triggerRefresh: args?['triggerRefresh'] == true,
        ),
      );
    case AppRoutes.categoryProducts:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryId: args?['categoryId'] as int,
          categoryName: args?['categoryName'] as String? ?? 'Products',
        ),
      );
    case AppRoutes.brandProducts:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => BrandProductsScreen(
          brandId: args?['brandId'] as int,
          brandName: args?['brandName'] as String? ?? 'Brand Products',
        ),
      );
    case AppRoutes.productDetails:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: args?['productId'] as int,
          isForSale: args?['isForSale'] as bool? ?? false,
          productNumber: args?['productNumber'] as String?,
        ),
      );
    case AppRoutes.cart:
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case AppRoutes.checkout:
      final args = settings.arguments;
      List<CartItemModel> cartItems = [];
      List<String>? itemColors;
      if (args is Map<String, dynamic>) {
        cartItems = (args['cartItems'] as List<dynamic>?)
                ?.cast<CartItemModel>() ??
            [];
        final colors = args['itemColors'] as List<dynamic>?;
        itemColors =
            colors?.map((e) => e?.toString() ?? '').cast<String>().toList();
      } else if (args is List) {
        cartItems = args is List<CartItemModel>
            ? args
            : (args).map((e) => e as CartItemModel).toList();
      }
      return MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: cartItems,
          itemColors: itemColors,
        ),
      );
    case AppRoutes.allProducts:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => AllProductsScreen(
          title: args?['title'] as String? ?? 'All Products',
          isBestProducts: args?['isBestProducts'] as bool? ?? false,
        ),
      );
    case AppRoutes.addReview:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => AddReviewScreen(
          productId: args?['productId'] as int,
          canWriteTextReview: args?['canWriteTextReview'] as bool? ?? true,
        ),
      );
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case AppRoutes.userInfo:
      return MaterialPageRoute(
        builder: (_) => const UserInfoScreen(),
      );
    case AppRoutes.orderDetails:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(
          orderNumber: args?['orderNumber'] as String? ?? '',
        ),
      );
    case AppRoutes.checkoutSuccess:
      final orderData = settings.arguments as CreateOrderDataModel?;
      if (orderData == null) {
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Order data missing'))),
        );
      }
      return MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(orderData: orderData),
      );
    case AppRoutes.termsAndConditions:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => sl<PublicSettingCubit>(),
          child: const TermsAndConditionsScreen(),
        ),
      );
    case AppRoutes.paymentWebView:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(
          url: args?['url'] as String? ?? '',
          successUrl: args?['successUrl'] as String? ??
              'https://yourdomain.com/tap/callback',
          failureUrl: args?['failureUrl'] as String? ??
              'https://yourdomain.com/tap/callback',
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))),
      );
  }
}
