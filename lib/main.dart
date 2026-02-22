import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constant/app_texts.dart';
import 'core/di/inject.dart' as di;
import 'core/localization/app_language.dart';
import 'core/localization/language_cubit.dart';
import 'core/network/dio_client.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/favorites/cubit/favorites_cubit.dart';
import 'features/home/cubit/search_cubit.dart';
import 'features/notifications/cubit/notifications_cubit.dart';
import 'features/settings/cubit/user_info_cubit.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env from .env (if present in assets) or .env.example
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    await dotenv.load(fileName: '.env.example');
  }

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  await di.init();

  final storageService = di.sl<StorageService>();
  final dioClient = di.sl<DioClient>();
  final token = storageService.getToken();
  if (token != null) {
    dioClient.setAuthToken(token);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        final languageCubit = di.sl<LanguageCubit>();
        return BlocProvider.value(
          value: languageCubit,
          child: BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              AppTexts.updateLocale(locale);
              final supportedLocales = AppLanguage.values
                  .map((lang) => lang.locale)
                  .toList(growable: false);

              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: di.sl<CartCubit>()),
                  BlocProvider.value(value: di.sl<FavoritesCubit>()),
                  BlocProvider.value(value: di.sl<SearchCubit>()),
                  BlocProvider.value(value: di.sl<UserInfoCubit>()),
                  BlocProvider.value(value: di.sl<NotificationsCubit>()),
                ],
                child: MaterialApp(
                  navigatorKey: navigatorKey,
                  title: 'IAM',
                  debugShowCheckedModeBanner: false,
                  locale: locale,
                  supportedLocales: supportedLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  theme: AppTheme.lightTheme,
                  onGenerateRoute: onGenerateAppRoute,
                  initialRoute: AppRoutes.splash,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
