import 'package:flutter_riverpod/legacy.dart';

enum ScreenType {
  dashboard,
  products,
  bomMaster,
  orders,
  suppliers,
  purchases,
  inventory,
}

var screenProvider = StateProvider<ScreenType>((ref) => ScreenType.dashboard);