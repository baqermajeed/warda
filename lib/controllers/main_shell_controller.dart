import 'package:get/get.dart';

/// تحكم الـ Shell الرئيسي (التبويبات).
class MainShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;
}
