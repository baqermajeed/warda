/// عنصر سؤال شائع.
class FaqItem {
  const FaqItem({
    required this.id,
    required this.questionKey,
    required this.answerKey,
  });

  final String id;
  final String questionKey;
  final String answerKey;
}

/// قسم أسئلة شائعة.
class FaqCategory {
  const FaqCategory({
    required this.id,
    required this.titleKey,
    required this.items,
  });

  final String id;
  final String titleKey;
  final List<FaqItem> items;
}
