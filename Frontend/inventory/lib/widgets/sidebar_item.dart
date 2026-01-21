import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.setIndex,
    required this.selectedIndex,
    required this.currentIndex,
    required this.imageName,
  });
  final void Function(int index) setIndex;
  final int selectedIndex;
  final int currentIndex;
  final String imageName;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setIndex(currentIndex),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            selectedIndex == currentIndex
                ? SvgPicture.asset(
                    imageName,

                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                    width: 14,
                    height: 14,
                  )
                : SvgPicture.asset(imageName, width: 14, height: 14),
            if (selectedIndex == currentIndex)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 3,
                  height: 60,
                  
                  decoration: BoxDecoration(
                    color:  Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
