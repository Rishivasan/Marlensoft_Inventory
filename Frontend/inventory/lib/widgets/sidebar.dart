import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/providers/sidebar_state.dart';
import 'package:inventory/providers/sidebar_expand_state.dart';
import 'package:inventory/widgets/sidebar_item.dart';

class SidebarWidget extends ConsumerWidget {
  SidebarWidget({super.key});

  void setSelectedIndex(int index, WidgetRef ref) {
    int temp = ref.read(sideBarStateProvider);
    if (temp != index) {
      ref.read(sideBarStateProvider.notifier).state = index;
    }
  }

  final List<String> svgAssets = [
    "assets/images/Frame676.svg",
    "assets/images/codesandbox.svg",
    "assets/images/link.svg",
    "assets/images/shopping-cart.svg",
    "assets/images/truck.svg",
    "assets/images/shopping-bag.svg",
    "assets/images/boxes.svg",
  ];

  // NEW labels (same order)
  final List<String> labels = [
    "Dashboard",
    "Products",
    "BOM Master",
    "Orders",
    "Suppliers",
    "Purchases",
    "Inventory",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int temp = ref.watch(sideBarStateProvider);

    // ✅ NEW expand state
    final bool isExpanded = ref.watch(sidebarExpandProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 210 : 70,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: isExpanded
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                // LOGO
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  alignment: isExpanded
                      ? Alignment.centerLeft
                      : Alignment.center,
                  padding: EdgeInsets.only(left: isExpanded ? 16 : 0),
                  child: SvgPicture.asset(
                    isExpanded
                        ? "assets/images/inveon 1.svg" //  200 width logo
                        : "assets/images/Group2.svg", //  70 width logo
                    width: isExpanded ? 120 : 26,
                  ),
                ),

                // MENU
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: svgAssets.length,
                    itemBuilder: (context, index) => SidebarItem(
                      setIndex: (index) {
                        setSelectedIndex(index, ref);

                        // 
                        // After selecting, you can call your routing logic from parent screen
                        // (we will connect this next step)
                      },
                      selectedIndex: temp,
                      currentIndex: index,
                      imageName: svgAssets[index],

                      // ✅ NEW
                      label: labels[index],
                      isExpanded: isExpanded,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Divider(
                  color: const Color.fromARGB(7, 0, 0, 0),
                  height: 2,
                  thickness: 2,
                  indent: 14,
                  endIndent: 14,
                ),

                // EXPAND BUTTON
                InkWell(
                  onTap: () {
                    ref.read(sidebarExpandProvider.notifier).state =
                        !isExpanded;
                  },
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/images/panel-right-open.svg",
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FOOTER LOGO
          // Container(
          //   height: 70,
          //   margin: const EdgeInsets.only(top: 8, bottom: 4),
          //   alignment: Alignment.center,
          //   child: SvgPicture.asset(
          //     "assets/images/New Logo with black subtext 1.svg",
          //     width: isExpanded ? 80 : 24,
          //   ),
          // ),
          Container(
                  height: 60,
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  alignment: isExpanded
                      ? Alignment.centerLeft
                      : Alignment.center,
                  padding: EdgeInsets.only(left: isExpanded ? 16 : 0),
                  child: SvgPicture.asset(
                    isExpanded
                        ? "assets/images/New Logo with black subtext 1.svg" //  200 width logo
                        : "assets/images/Frame2094.svg", //  70 width logo
                    width: isExpanded ? 140 : 26,
                  ),
                ),
        ],
      ),
    );
  }
}

