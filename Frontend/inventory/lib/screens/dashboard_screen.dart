import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:inventory/providers/header_state.dart';
// import 'package:inventory/providers/sidebar_state.dart';
// import 'package:inventory/routers/app_router.dart';
import 'package:inventory/screens/dashboard_body.dart';
import 'package:inventory/widgets/sidebar.dart';


// @RoutePage()
// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   @override
//   Widget build(BuildContext context) {
//     ref.watch(sideBarStateProvider);
//     return Scaffold(
//       body: Row(children: [SidebarWidget(), DashboardBodyScreen()]),
//     );
//   }
// }


// @override
// Widget build(BuildContext context) {
//   ref.listen<int>(sideBarStateProvider, (previous, next) {
//     if (previous == next) return;

//     // Update header based on index
//     switch (next) {
//       case 0:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "Dashboard",
//           subtitle: "Track all the datas from here",
//         );
//         context.router.replace(const DefaultRoute());
//         break;

//       case 1:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "Products",
//           subtitle: "Manage and track all products available in your inventory system.",
//         );
//         context.router.replace(const DefaultRoute());
//         break;

//       case 2:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "BOM Master",
//           subtitle: "Manage and track all BOM available in your inventory system.",
//         );
//         context.router.replace(const DefaultRoute());
//         break;

//       case 3:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "Orders",
//           subtitle: "View and manage all orders in your system.",
//         );
//         context.router.replace(const DefaultRoute());
//         break;

//       case 4:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "Suppliers",
//           subtitle: "Manage suppliers and their details.",
//         );
//         context.router.replace(const DefaultRoute());
//         break;

//       case 5:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "Purchases",
//           subtitle: "Track all purchase records and invoices.",
//         );
//         context.router.replace(const DefaultRoute());
//         break;

//       case 6:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "Tools, Assets, MMDs & Consumables Management",
//           subtitle:
//               "Here you can have a centralized system to maintain, track, and manage all equipment and resources",
//         );
//         context.router.replace(const MasterListRoute());
//         break;

//       default:
//         ref.read(headerProvider.notifier).state = HeaderModel(
//           title: "Dashboard",
//           subtitle: "Welcome! Select a menu to view details.",
//         );
//         context.router.replace(const DefaultRoute());
//     }
//   });

//   return Scaffold(
//     body: Row(
//       children: [
//         SidebarWidget(),
//         DashboardBodyScreen(),
//       ],
//     ),
//   );
// }


// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:inventory/screens/dashboard_body.dart';
// import 'package:inventory/widgets/sidebar.dart';

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

