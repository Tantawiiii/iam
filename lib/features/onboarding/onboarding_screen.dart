import 'package:iam/core/constant/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iam/features/onboarding/widgets/dots_widget.dart';
import 'package:iam/features/onboarding/widgets/onboard_page.dart';
import 'package:iam/features/settings/cubit/public_setting_cubit.dart';
import 'package:iam/features/settings/cubit/public_setting_state.dart';

import '../../core/constant/app_assets.dart';
import '../../core/constant/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/widgets/language_switcher.dart';
import 'model/onboard_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<PublicSettingCubit>().getPublicSettings();
  }

  void _goNext(int length) {
    if (_index < length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<PublicSettingCubit, PublicSettingState>(
        builder: (context, state) {
          if (state is PublicSettingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<OnboardData> pages = [];

          if (state is PublicSettingSuccess) {
            final data = state.data;
            if (data.promotionalOfferImageOne != null && data.titleOne != null) {
              pages.add(OnboardData(
                  image: data.promotionalOfferImageOne!, title: data.titleOne!));
            }
            if (data.promotionalOfferImageTwo != null && data.titleTwo != null) {
              pages.add(OnboardData(
                  image: data.promotionalOfferImageTwo!, title: data.titleTwo!));
            }
            if (data.promotionalOfferImageThree != null &&
                data.titleThree != null) {
              pages.add(OnboardData(
                  image: data.promotionalOfferImageThree!,
                  title: data.titleThree!));
            }
            if (data.promotionalOfferImageFour != null &&
                data.titleFour != null) {
              pages.add(OnboardData(
                  image: data.promotionalOfferImageFour!,
                  title: data.titleFour!));
            }
            if (data.promotionalOfferImageFive != null &&
                data.titleFive != null) {
              pages.add(OnboardData(
                  image: data.promotionalOfferImageFive!,
                  title: data.titleFive!));
            }
          }


          if (pages.isEmpty) {
            pages = [
              OnboardData(image: AppAssets.onboard1Img, title: AppTexts.onTitle1),
              OnboardData(image: AppAssets.onboard2Img, title: AppTexts.onTitle2),
              OnboardData(image: AppAssets.onboard3Img, title: AppTexts.onTitle3),
              OnboardData(image: AppAssets.onboard4Img, title: AppTexts.onTitle4),
              OnboardData(image: AppAssets.onboard5Img, title: AppTexts.onTitle5),
              OnboardData(image: AppAssets.onboard6Img, title: AppTexts.onTitle6),
            ];
          }

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${_index + 1}/${pages.length}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                     // const LanguageSwitcher(compact: true),
                      SizedBox(width: 12.w),
                      TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: Text(
                          AppTexts.skip,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: pages.length,
                    itemBuilder: (_, i) => OnboardPage(data: pages[i]),
                  ),
                ),
                SizedBox(height: 16.h),
                Dots(index: _index, length: pages.length),
                SizedBox(height: 24.h),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Row(
                    children: [
                      if (_index > 0)
                        TextButton(
                          onPressed: () => _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 14.h,
                            ),
                          ),
                          child: Text(
                            AppTexts.prev,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _goNext(pages.length),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: Size(140.w, 52.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            _index == pages.length - 1
                                ? AppTexts.getStarted
                                : AppTexts.next,
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}