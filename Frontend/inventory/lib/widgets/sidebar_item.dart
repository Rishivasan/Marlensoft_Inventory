import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.setIndex,
    required this.selectedIndex,
    required this.currentIndex,
    required this.imageName,
    required this.label,
    required this.isExpanded,
  });

  final void Function(int index) setIndex;
  final int selectedIndex;
  final int currentIndex;
  final String imageName;

  final String label;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == currentIndex;

    return InkWell(
      onTap: () => setIndex(currentIndex),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ICON always center when collapsed
            Align(
              alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(left: isExpanded ? 16 : 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isSelected
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

                    // LABEL only when expanded
                    if (isExpanded) ...[
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : const Color.fromRGBO(88, 88, 88, 1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // KEEP your selection indicator (same)
            if (isSelected)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 3,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.only(
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

