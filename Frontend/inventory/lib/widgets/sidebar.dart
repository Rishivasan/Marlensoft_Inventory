import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/providers/sidebar_state.dart';
import 'package:inventory/widgets/sidebar_item.dart';


class SidebarWidget extends ConsumerWidget {
  SidebarWidget({super.key});

  void setSelectedIndex(int index, WidgetRef ref) {
    int temp = ref.read(sideBarStateProvider);
    if (temp != index) {
      // print(index);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int temp = ref.watch(sideBarStateProvider);
    return Container(
      width: 70,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  margin: EdgeInsets.only(top: 8, bottom: 4),
                  // decoration: BoxDecoration(border: Border.all(width: 2)),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/images/Group2.svg",
                    width: 26,
                  ),
                ),
                SizedBox(
                  height: 255,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: svgAssets.length,

                    itemBuilder: (context, index) => SidebarItem(
                      setIndex: (index) {
                        setSelectedIndex(index, ref);
                      },
                      selectedIndex: temp,
                      currentIndex: index,
                      imageName: svgAssets[index],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Divider(
                  color: Color.fromARGB(7, 0, 0, 0),
                  height: 2,
                  thickness: 2,
                  indent: 14,
                  endIndent: 14,
                ),
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/images/panel-right-open.svg",
                    width: 16,
                    height: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            margin: EdgeInsets.only(top: 8, bottom: 4),
            // decoration: BoxDecoration(border: Border.all(width: 2)),
            alignment: Alignment.center,
            child: SvgPicture.asset("assets/images/Frame2094.svg", width: 24),
          ),
        ],
      ),
    );
  }
}
