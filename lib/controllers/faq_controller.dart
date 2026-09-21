import 'package:get/get.dart';

import '../models/faq_item.dart';

/// تحكم شاشة الأسئلة الشائعة.
class FaqController extends GetxController {
  /// معرّف السؤال المفتوح حاليًا (Accordion).
  final expandedId = RxnString();

  final categories = const <FaqCategory>[
    FaqCategory(
      id: 'orders',
      titleKey: 'faq_cat_orders',
      items: [
        FaqItem(
          id: 'o1',
          questionKey: 'faq_q_how_order',
          answerKey: 'faq_a_how_order',
        ),
        FaqItem(
          id: 'o2',
          questionKey: 'faq_q_track',
          answerKey: 'faq_a_track',
        ),
        FaqItem(
          id: 'o3',
          questionKey: 'faq_q_cancel',
          answerKey: 'faq_a_cancel',
        ),
      ],
    ),
    FaqCategory(
      id: 'delivery',
      titleKey: 'faq_cat_delivery',
      items: [
        FaqItem(
          id: 'd1',
          questionKey: 'faq_q_delivery_areas',
          answerKey: 'faq_a_delivery_areas',
        ),
        FaqItem(
          id: 'd2',
          questionKey: 'faq_q_delivery_time',
          answerKey: 'faq_a_delivery_time',
        ),
        FaqItem(
          id: 'd3',
          questionKey: 'faq_q_same_day',
          answerKey: 'faq_a_same_day',
        ),
      ],
    ),
    FaqCategory(
      id: 'payment',
      titleKey: 'faq_cat_payment',
      items: [
        FaqItem(
          id: 'p1',
          questionKey: 'faq_q_payment_methods',
          answerKey: 'faq_a_payment_methods',
        ),
        FaqItem(
          id: 'p2',
          questionKey: 'faq_q_invoice',
          answerKey: 'faq_a_invoice',
        ),
      ],
    ),
    FaqCategory(
      id: 'gifts',
      titleKey: 'faq_cat_gifts',
      items: [
        FaqItem(
          id: 'g1',
          questionKey: 'faq_q_customize',
          answerKey: 'faq_a_customize',
        ),
        FaqItem(
          id: 'g2',
          questionKey: 'faq_q_card',
          answerKey: 'faq_a_card',
        ),
        FaqItem(
          id: 'g3',
          questionKey: 'faq_q_fresh',
          answerKey: 'faq_a_fresh',
        ),
      ],
    ),
  ];

  void toggle(String id) {
    if (expandedId.value == id) {
      expandedId.value = null;
    } else {
      expandedId.value = id;
    }
  }

  bool isExpanded(String id) => expandedId.value == id;
}
