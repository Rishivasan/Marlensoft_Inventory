import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/screens/dashboard_body.dart';
import 'package:inventory/widgets/sidebar.dart';



@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          SidebarWidget(),
          DashboardBodyScreen(),
        ],
      ),
    );
  }
}

