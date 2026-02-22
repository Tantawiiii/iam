import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/localization/language_cubit.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/language_switcher.dart';
import '../../auth/services/auth_service.dart';
import '../cubit/update_profile_cubit.dart';
import '../cubit/resell_product_cubit.dart';
import '../../contact_us/cubit/contact_us_cubit.dart';
import 'update_profile_tab.dart';
import 'resell_product_tab.dart';
import 'user_info_screen.dart';
import '../../contact_us/ui/contact_us_tab.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openMyAccount(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.userInfo);
  }

  void _openUpdateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<UpdateProfileCubit>(),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.horizontalGradient.createShader(bounds),
                child: Text(
                  AppTexts.updateProfile,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const UpdateProfileTab(),
          ),
        ),
      ),
    );
  }

  void _openContactUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<ContactUsCubit>()),
            BlocProvider.value(value: context.read<LanguageCubit>()),
          ],
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.horizontalGradient.createShader(bounds),
                child: Text(
                  AppTexts.contactUs,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const ContactUsTab(),
          ),
        ),
      ),
    );
  }

  void _openResellProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<ResellProductCubit>(),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.horizontalGradient.createShader(bounds),
                child: Text(
                  AppTexts.resellProduct,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const ResellProductTab(),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTexts.logout),
        content: Text(AppTexts.logoutConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppTexts.logout),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await di.sl<AuthService>().logout();
    } catch (_) {}

    await di.sl<StorageService>().clearAuthData();
    di.sl<DioClient>().clearAuthToken();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageCubit>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.horizontalGradient.createShader(bounds),
          child: Text(
            AppTexts.settings,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        children: [
          _SettingsTile(
            icon: Icons.account_circle_outlined,
            iconColor: AppColors.primary,
            title: AppTexts.myAccount,
            subtitle: AppTexts.myAccount,
            onTap: () => _openMyAccount(context),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            iconColor: AppColors.primary,
            title: AppTexts.language,
            subtitle: AppTexts.changeLanguage,
            trailing: const LanguageSwitcher(),
          ),
          _SettingsTile(
            icon: Icons.person_outline,
            iconColor: AppColors.primary,
            title: AppTexts.updateProfile,
            subtitle: AppTexts.editYourInfo,
            onTap: () => _openUpdateProfile(context),
          ),
          _SettingsTile(
            icon: Icons.support_agent_outlined,
            iconColor: AppColors.primary,
            title: AppTexts.contactUs,
            subtitle: AppTexts.sendUsMessage,
            onTap: () => _openContactUs(context),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
            title: AppTexts.termsAndConditions,
            subtitle: AppTexts.readTermsAndConditions,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.termsAndConditions);
            },
          ),
          // _SettingsTile(
          //   icon: Icons.sell_outlined,
          //   iconColor: Colors.orange,
          //   title: AppTexts.resellProduct,
          //   subtitle: AppTexts.resellProductSubtitle,
          //   onTap: () => _openResellProduct(context),
          // ),
          SizedBox(height: 16.h),
          _SettingsTile(
            icon: Icons.logout,
            iconColor: AppColors.error,
            title: AppTexts.logout,
            subtitle: AppTexts.signOutReturn,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: iconColor, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right, color: AppColors.textSecondary)
                : null),
        onTap: onTap,
      ),
    );
  }
}
