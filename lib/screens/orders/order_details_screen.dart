import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/orders_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_image.dart';

/// شاشة تفاصيل الطلب.
class OrderDetailsScreen extends GetView<OrdersController> {
  const OrderDetailsScreen({super.key});

  static const _sectionTitle = Color(0xFF96705B);
  static const _valueMuted = Color(0xCC555553);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = controller.selectedOrder;
      if (order == null) {
        return Scaffold(body: Center(child: Text('orders_empty_detail'.tr)));
      }

      return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
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
                  Text(
                    'orders_detail_title'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 29.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                children: [
                  _SectionLabel('orders_section_recipient'.tr),
                  SizedBox(height: 16.h),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        label: '${'orders_label_name'.tr} :',
                        value: order.recipient.name,
                      ),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: '${'orders_label_phone'.tr} :',
                        value: order.recipient.phone,
                      ),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: '${'orders_label_gov'.tr} :',
                        value: order.recipient.governorate,
                      ),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: '${'orders_label_landmark'.tr} :',
                        value: order.recipient.landmark,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _SectionLabel('orders_detail_title'.tr),
                  SizedBox(height: 16.h),
                  _InfoCard(
                    children: [
                      _InfoRow(label: '${'orders_label_number'.tr} :', value: order.code),
                      SizedBox(height: 11.h),
                      _InfoRow(label: '${'orders_label_date'.tr} :', value: order.date),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: '${'orders_label_count'.tr} :',
                        value: 'common_product_count'.trParams({'count': '${order.productsCount}'}),
                      ),
                      SizedBox(height: 11.h),
                      Divider(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: '${'orders_label_status'.tr} :',
                        value: order.status.label,
                        valueColor: order.status.textColor,
                        valueBold: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _SectionLabel('orders_products'.tr),
                  SizedBox(height: 16.h),
                  for (final item in order.items) ...[
                    _ProductRow(item: item),
                    SizedBox(height: 12.h),
                  ],
                  _SectionLabel('orders_label_gift_card'.tr),
                  SizedBox(height: 16.h),
                  _GiftCardsRow(
                    cards: order.giftCards,
                    priceLabel: order.giftCards.first.priceLabel,
                  ),
                  SizedBox(height: 16.h),
                  _SectionLabel('orders_label_wrapping'.tr),
                  SizedBox(height: 16.h),
                  _WrapRow(wrap: order.wrap),
                  SizedBox(height: 16.h),
                  _SectionLabel('orders_label_price_details'.tr),
                  SizedBox(height: 16.h),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        label: 'basket_order_price'.tr,
                        value: order.priceDetails.orderPrice,
                      ),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: 'basket_delivery_price'.tr,
                        value: order.priceDetails.deliveryLabel.tr,
                      ),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: '${'orders_payment_method'.tr} :',
                        value: order.priceDetails.paymentMethod.tr,
                      ),
                      SizedBox(height: 11.h),
                      Divider(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                      SizedBox(height: 11.h),
                      _InfoRow(
                        label: 'basket_total'.tr,
                        value: order.priceDetails.totalPrice,
                        valueColor: AppColors.successGreen,
                        valueBold: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 97.h,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 19.w, 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(23.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.13),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 50.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.reorder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingCta,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23.r),
                    ),
                  ),
                  child: Text(
                    'orders_reorder'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: OrderDetailsScreen._sectionTitle,
        height: 1.5,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: 0.45),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor = OrderDetailsScreen._valueMuted,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: valueBold ? FontWeight.w600 : FontWeight.w400,
              color: valueColor,
              height: 1.5,
            ),
          ),
        ),
        const Spacer(),
        Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.onboardingText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.item});

  final OrderLineItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 78.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: 0.45),
            blurRadius: 3.4,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            item.priceLabel,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.title.tr,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3D3E46),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '${'orders_label_qty'.tr} : ${item.qty}',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3D3E46).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          ),
          SizedBox(width: 10.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: AppImage(
              source: item.imageAsset,
              width: 69.w,
              height: 61.h,
              fallbackAsset: 'assets/images/orders/product.jpg',
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftCardsRow extends StatelessWidget {
  const _GiftCardsRow({
    required this.cards,
    required this.priceLabel,
  });

  final List<OrderGiftCard> cards;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 107.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: 0.45),
            blurRadius: 3.4,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            priceLabel,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
          const Spacer(),
          for (final card in cards.take(2)) ...[
            _ThumbWithExpand(imageAsset: card.imageAsset, width: 114.w, height: 86.h),
            SizedBox(width: 10.w),
          ],
        ],
      ),
    );
  }
}

class _WrapRow extends StatelessWidget {
  const _WrapRow({required this.wrap});

  final OrderWrap wrap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 66.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: 0.45),
            blurRadius: 3.4,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            wrap.priceLabel,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              wrap.title,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3D3E46),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: AppImage(
              source: wrap.imageAsset,
              width: 54.w,
              height: 48.h,
              fallbackAsset: 'assets/images/orders/product.jpg',
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbWithExpand extends StatelessWidget {
  const _ThumbWithExpand({
    required this.imageAsset,
    required this.width,
    required this.height,
  });

  final String imageAsset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AppImage(
                source: imageAsset,
                fallbackAsset: 'assets/images/orders/product.jpg',
              ),
            ),
          ),
          Positioned(
            left: 6.w,
            bottom: 6.h,
            child: Container(
              width: 20.w,
              height: 18.5.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: SvgPicture.asset(
                'assets/icons/orders/maximize.svg',
                width: 12.w,
                height: 12.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
