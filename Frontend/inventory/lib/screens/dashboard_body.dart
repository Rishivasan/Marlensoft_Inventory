// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:inventory/providers/sidebar_state.dart';
// import 'package:inventory/routers/app_router.dart';
// import 'package:inventory/widgets/footer.dart';
// import 'package:inventory/widgets/nav_profile.dart';


// class DashboardBodyScreen extends ConsumerWidget {
//   DashboardBodyScreen({super.key});

//     @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // int temp = ref.read(sideBarStateProvider);
//     // switch(temp){
//     //  case 6: context.router.replace(MasterListRoute());
//     //  default:context.router.replace(DefaultRoute());
//     // }
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 24),
//         decoration: BoxDecoration(color: Color(0xFFF4F4F4)),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 20),

//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Tools, Assets, MMDs & Consumables Management',
//                         style: Theme.of(context).textTheme.displayMedium,
//                       ),
//                       Text(
//                         'Here you can have a centralized system to maintain, track, and manage all equipment and resources',
//                       ),
//                     ],
//                   ),

//                   NavbarProfileWidget(),
//                 ],
//               ),
//             ),

//            Expanded(child: AutoRouter()),
           
//           Container(
//             height: 50,
//             alignment: Alignment.center,
//             child: FooterWidget(),
//           )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/providers/header_state.dart';
import 'package:inventory/providers/sidebar_state.dart';
import 'package:inventory/routers/app_router.dart';
import 'package:inventory/widgets/footer.dart';
import 'package:inventory/widgets/nav_profile.dart';

class DashboardBodyScreen extends ConsumerWidget {
  DashboardBodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //  Listen sidebar change and update header + route
    ref.listen<int>(sideBarStateProvider, (previous, next) {
      if (previous == next) return;

      switch (next) {
        case 0:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Dashboard",
            subtitle: "Welcome to Dashboard screen",
          );
          context.router.replace(const DefaultRoute());
          break;

        case 1:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Products",
            subtitle: "Manage and track your products here",
          );
          context.router.replace(const DefaultRoute());
          break;

        case 2:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "BOM Master",
            subtitle: "Manage your BOM master details here",
          );
          context.router.replace(const DefaultRoute());
          break;

        case 3:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Orders",
            subtitle: "View and manage all orders here",
          );
          context.router.replace(const DefaultRoute());
          break;

        case 4:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Suppliers",
            subtitle: "Track and manage supplier details here",
          );
          context.router.replace(const DefaultRoute());
          break;

        case 5:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Purchases",
            subtitle: "Manage purchase records here",
          );
          context.router.replace(const DefaultRoute());
          break;

        case 6:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Tools, Assets, MMDs & Consumables Management",
            subtitle:
                "Here you can have a centralized system to maintain, track, and manage all equipment and resources",
          );
          context.router.replace( MasterListRoute());
          break;

        default:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Dashboard",
            subtitle: "Welcome! Select a menu to view details.",
          );
          context.router.replace(const DefaultRoute());
      }
    });

    // Get header data
    final header = ref.watch(headerProvider);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(color: Color(0xFFF4F4F4)),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header.title,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(header.subtitle),
                    ],
                  ),
                  NavbarProfileWidget(),
                ],
              ),
            ),

            // BODY CONTENT
            const Expanded(child: AutoRouter()),

            // FOOTER
            Container(
              height: 50,
              alignment: Alignment.center,
              child: FooterWidget(),
            ),
          ],
        ),
      ),
    );
  }
}


