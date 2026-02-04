import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/providers/header_state.dart';
import 'package:inventory/providers/sidebar_state.dart';
import 'package:inventory/providers/screen_provider.dart';
import 'package:inventory/routers/app_router.dart';
import 'package:inventory/screens/qc_template_screen.dart';
import 'package:inventory/widgets/footer.dart';
import 'package:inventory/widgets/nav_profile.dart';

class DashboardBodyScreen extends ConsumerWidget {
  const DashboardBodyScreen({super.key});

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
          ref.read(screenProvider.notifier).state = ScreenType.dashboard;
          context.router.replace(const DefaultRoute());
          break;

        case 1:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Products",
            subtitle: "Manage and track your products here",
          );
          ref.read(screenProvider.notifier).state = ScreenType.products;
          context.router.replace(const DefaultRoute());
          break;

        case 2:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Quality Check Customization",
            subtitle: "Configure quality control templates and inspection points for BOM Master",
          );
          // Set screen to show QC Template
          ref.read(screenProvider.notifier).state = ScreenType.bomMaster;
          break;

        case 3:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Orders",
            subtitle: "View and manage all orders here",
          );
          ref.read(screenProvider.notifier).state = ScreenType.orders;
          context.router.replace(const DefaultRoute());
          break;

        case 4:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Suppliers",
            subtitle: "Track and manage supplier details here",
          );
          ref.read(screenProvider.notifier).state = ScreenType.suppliers;
          context.router.replace(const DefaultRoute());
          break;

        case 5:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Purchases",
            subtitle: "Manage purchase records here",
          );
          ref.read(screenProvider.notifier).state = ScreenType.purchases;
          context.router.replace(const DefaultRoute());
          break;

        case 6:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Tools, Assets, MMDs & Consumables Management",
            subtitle:
                "Here you can have a centralized system to maintain, track, and manage all equipment and resources",
          );
          ref.read(screenProvider.notifier).state = ScreenType.inventory;
          context.router.replace( MasterListRoute());
          break;

        default:
          ref.read(headerProvider.notifier).state = const HeaderModel(
            title: "Dashboard",
            subtitle: "Welcome! Select a menu to view details.",
          );
          ref.read(screenProvider.notifier).state = ScreenType.dashboard;
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
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final currentScreen = ref.watch(screenProvider);
                  
                  // Show QC Template Screen for BOM Master
                  if (currentScreen == ScreenType.bomMaster) {
                    return const QCTemplateScreen();
                  }
                  
                  // Default router content for other screens
                  return const AutoRouter();
                },
              ),
            ),

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


