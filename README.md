# warda

مشروع Flutter بهيكلة **GetX MVC** بنفس أسلوب مشروع «قريب».

## الهيكلة

```
lib/
├── controllers/     # منطق الأعمال والحالة (GetxController)
├── core/
│   ├── config/      # إعدادات API
│   ├── errors/      # استثناءات
│   └── theme/       # ألوان وثيم
├── models/          # نماذج البيانات فقط
├── screens/         # الواجهات (UI فقط — StatelessWidget)
├── services/        # API، تخزين التوكن، ...
├── utils/           # أدوات مساعدة
├── widgets/         # مكونات مشتركة
└── main.dart
```

## التشغيل

```bash
flutter pub get
flutter run
```

## المعايير

- GetX للحالة والتنقل
- StatelessWidget للواجهات
- flutter_screenutil للقياسات المتجاوبة
- منطق الأعمال داخل الـ Controllers فقط
