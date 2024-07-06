import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavProvider = StateNotifierProvider<PageIndexNavigator, int>(
  PageIndexNavigator.new,
);

class PageIndexNavigator extends StateNotifier<int> {
  PageIndexNavigator(this.ref) : super(0);
  final Ref ref;

  void setPageIndex(int index) {
    state = index;
  }
}
