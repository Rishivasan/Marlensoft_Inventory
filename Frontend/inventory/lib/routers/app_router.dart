import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:inventory/screens/dashboard_screen.dart';
import 'package:inventory/screens/default_screen.dart';
import 'package:inventory/screens/master_list.dart';
import 'package:inventory/screens/product_detail_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: DashboardRoute.page, initial: true, children: [
      AutoRoute(page: MasterListRoute.page), 
      AutoRoute(page: DefaultRoute.page, initial: true),
      AutoRoute(page: ProductDetailRoute.page),
    ]),
  ];
}



