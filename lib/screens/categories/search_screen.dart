import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/categories_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة البحث مع سجل البحث — حسب تصميم Figma.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final CategoriesController _controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CategoriesController>();
    _textController = TextEditingController(text: _controller.searchQuery.value);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 18.sp,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'search_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingText,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _SearchInput(
                controller: _textController,
                autofocus: true,
                onChanged: _controller.onSearchChanged,
                onSubmitted: (v) async {
                  await _controller.submitSearch(v);
                },
                onClear: () {
                  _textController.clear();
                  _controller.onSearchChanged('');
                },
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Obx(
                    () => _controller.searchHistory.isEmpty
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: _controller.clearHistory,
                            child: Text(
                              'common_clear_all'.tr,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.authLink,
                              ),
                            ),
                          ),
                  ),
                  const Spacer(),
                  Text(
                    'search_history'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                if (_controller.searchHistory.isEmpty) {
                  return Center(
                    child: Text(
                      'search_history_empty'.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13.sp,
                        color: AppColors.onboardingText.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: _controller.searchHistory.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final item = _controller.searchHistory[index];
                    return _HistoryTile(
                      label: item,
                      onTap: () async {
                        _textController.text = item;
                        await _controller.submitSearch(item);
                      },
                      onDelete: () => _controller.removeHistoryItem(item),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: 0.45),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: const BoxDecoration(
                color: AppColors.onboardingCta,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.close, size: 16.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onboardingText,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'search_hint'.tr,
                hintStyle: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingText.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          SvgPicture.asset(
            'assets/icons/categories/search.svg',
            width: 22.w,
            height: 22.w,
            colorFilter: const ColorFilter.mode(
              AppColors.onboardingText,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: AppColors.authLink,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingText,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              Icons.history,
              size: 18.sp,
              color: AppColors.authLink,
            ),
          ],
        ),
      ),
    );
  }
}
