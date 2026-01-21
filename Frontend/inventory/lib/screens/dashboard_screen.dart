import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/providers/sidebar_state.dart';
import 'package:inventory/screens/dashboard_body.dart';
import 'package:inventory/widgets/sidebar.dart';


@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(sideBarStateProvider);
    return Scaffold(
      body: Row(children: [SidebarWidget(), DashboardBodyScreen()]),
    );
  }
}
