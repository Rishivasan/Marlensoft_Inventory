import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavbarProfileWidget extends StatefulWidget {
  const NavbarProfileWidget({super.key});

  @override
  State<NavbarProfileWidget> createState() => _NavbarProfileWidgetState();
}

class _NavbarProfileWidgetState extends State<NavbarProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Add dropdown menu functionality
        print('Profile dropdown clicked');
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          spacing: 5,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xff00599A), width: 2),
                image: const DecorationImage(
                  image: AssetImage("assets/images/userprofile.jpg"),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  'Administrator',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/images/Dropdown_arrow_down.svg',
              width: 6,
              height: 6,
              colorFilter: const ColorFilter.mode(
                Color(0xFF374151),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

