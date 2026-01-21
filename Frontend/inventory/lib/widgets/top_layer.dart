import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopLayer extends StatelessWidget {
  const TopLayer({super.key});
  
  bool get isButtonEnabled => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 440,
                height: 35,
                child: SearchBar(
                  elevation: WidgetStatePropertyAll(0),
                  
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                  hintText: 'Search',
                  padding: WidgetStatePropertyAll(
                    EdgeInsetsGeometry.only(left: 6, bottom: 2),
                  ),
                  hintStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.bodyMedium,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color(0xff909090), // border color
                        width: 1, // border width
                      ),
                      borderRadius: BorderRadiusGeometry.all(Radius.circular(6)),
                    ),
                  ),
                  trailing: [
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset("assets/images/Vector.svg", width: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      onPressed:() {}, //For delete
                      
                      height: 45,
                      minWidth: 90,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                        side: BorderSide(
                          color: isButtonEnabled
                              ? Theme.of(context).primaryColor
                              : Color.fromRGBO(144, 144, 144, 1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          
                          color: isButtonEnabled
                              ? Theme.of(context).primaryColor
                             : Color.fromRGBO(144, 144, 144, 1),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    MaterialButton(
                      onPressed:() {},
                      height: 45,
                      minWidth: 90,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                        side: BorderSide(
                          color: isButtonEnabled
                              ? Theme.of(context).primaryColor
                              : Color.fromRGBO(144, 144, 144, 1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Export",
                        style: TextStyle(
                          color: isButtonEnabled
                              ? Theme.of(context).primaryColor
                              : Color.fromRGBO(144, 144, 144, 1),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),

SizedBox(
  width: 160,
  height: 42,
  child: PopupMenuButton<String>(
    onSelected: (value) {
      // ✅ Open Drawer first
      Scaffold.of(context).openDrawer();

      // ✅ After opening drawer, navigate based on selection
      Future.delayed(const Duration(milliseconds: 200), () {
        if (value == "tool") {
          // TODO: change to your drawer navigation logic
          print("Go to Add Tool Page");
        } else if (value == "asset") {
          print("Go to Add Asset Page");
        } else if (value == "mmd") {
          print("Go to Add MMD Page");
        } else if (value == "consumable") {
          print("Go to Add Consumable Page");
        }
      });
    },
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: "tool",
        child: Text("Add tool"),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: "asset",
        child: Text("Add asset"),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: "mmd",
        child: Text("Add MMD"),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: "consumable",
        child: Text("Add consumable"),
      ),
    ],
    child: ElevatedButton(
      onPressed: null, // popup handles click
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Add new item"),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    ),
  ),
),

                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}