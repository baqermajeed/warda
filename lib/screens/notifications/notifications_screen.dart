import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/notifications_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة الإشعارات — بنفس نمط شاشة الطلبات.
class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      'assets/icons/home/caret.svg',
                      width: 23.w,
                      height: 23.w,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'notifications_title'.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingText,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Obx(
                    () => controller.unreadCount.value == 0
                        ? const SizedBox.shrink()
                        : TextButton(
                            onPressed: controller.markAllRead,
                            child: Text(
                              'notifications_mark_all_read'.tr,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.authLink,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 23.h),
            Expanded(
              child: Obx(() {
                final items = controller.items;
                if (controller.isLoading.value && items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (items.isEmpty) {
                  return _EmptyState(
                    message: controller.errorMessage.value ??
                        'notifications_empty'.tr,
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.load,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.extentAfter < 300) controller.loadMore();
                      return false;
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => SizedBox(height: 16.h),
                      itemBuilder: (_, i) {
                        final n = items[i];
                        return _NotificationCard(
                          notification: n,
                          onTap: () => controller.openNotification(n),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'reminder':
        return Icons.event_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.onboardingCta.withValues(alpha: 0.16),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.onboardingCta.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: AppColors.onboardingCta, size: 22.w),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                      color: AppColors.onboardingText,
                      height: 1.5,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF555553),
                      ),
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Text(
                    notification.dateLabel,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF555553).withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.only(top: 6.h),
                decoration: const BoxDecoration(
                  color: AppColors.authLink,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56.w,
              color: AppColors.onboardingCta.withValues(alpha: 0.5),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
