import 'package:flutter/material.dart';

class NavbarProfileWidget extends StatelessWidget {
  const NavbarProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Color(0xff00599A), width: 2),
              image: DecorationImage(
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
        ],
      ),
    );
  }
}

