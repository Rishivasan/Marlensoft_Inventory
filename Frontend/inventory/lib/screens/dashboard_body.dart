import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/model/employee_table_model.dart';
import 'package:inventory/widgets/footer.dart';
import 'package:inventory/widgets/nav_profile.dart';
import 'package:inventory/widgets/top_layer.dart';


class DashboardBodyScreen extends StatelessWidget {
  DashboardBodyScreen({super.key});
  final List<EmployeeTableModel> employees = [
    EmployeeTableModel(
      Asset: 101,
      Type:"Weightbalance",
      AssetName: "LPA",
      Supplier: "TATA",
      Location: "Chennai",
    ),
    EmployeeTableModel(
      Asset: 102,
      Type:"Weightbalance",
      AssetName: "LPA",
      Supplier: "TATA",
      Location: "Chennai",
    ),
    EmployeeTableModel(
      Asset: 103,
      Type:"Weightbalance",
      AssetName: "LPA",
      Supplier: "TATA",
      Location: "Chennai",
    ),
    EmployeeTableModel(
      Asset: 103,
      Type:"Weightbalance",
      AssetName: "LPA",
      Supplier: "TATA",
      Location: "Chennai",
    ),
    EmployeeTableModel(
      Asset: 103,
      Type:"Weightbalance",
      AssetName: "LPA",
      Supplier: "TATA",
      Location: "Chennai",
    ),
    EmployeeTableModel(
      Asset: 103,
      Type:"Weightbalance",
      AssetName: "LPA",
      Supplier: "TATA",
      Location: "Chennai",
    ),
    
   
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: Color(0xFFF4F4F4)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tools, Assets, MMDs & Consumables Management',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        'Here you can have a centralized system to maintain, track, and manage all equipment and resources',
                      ),
                    ],
                  ),

                  NavbarProfileWidget(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    TopLayer(),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: DataTable(
                        headingRowHeight: 50,
                        dataRowMaxHeight: 54,
              
                        columns: [
                          DataColumn(
                            label: Transform.scale(
                              scale: 0.7,
                              child: Checkbox(value: false, onChanged: (val) {}),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                "Asset ID",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 40,
                              child: Text(
                                "Type",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 180,
                              child: Text(
                                "Asset Name",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 60,
                              child: Text(
                                "Supplier",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 70,
                              child: Text(
                                "Location",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                          DataColumn(label: Text('')),
                        ],
                        rows: employees.map((e) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Transform.scale(
                                  scale: 0.7,
                                  child: Checkbox(
                                    value: false,
                                    onChanged: (val) {},
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 80,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    e.Asset.toString(),
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    e.Type,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                              ),
                              // DataCell(
                              //   SizedBox(
                              //     width: 180,
                              //     height: 20,
                              //     child: ListView.builder(
                              //       scrollDirection: Axis.horizontal,
                              //       physics: NeverScrollableScrollPhysics(),
                              //       itemCount: e.AssetName.length,
                              //       itemBuilder: (context, index) => Container(
                              //         margin: EdgeInsets.symmetric(horizontal: 4),
                              //         padding: EdgeInsets.symmetric(
                              //           horizontal: 10,
                              //         ),
                              //         alignment: Alignment.center,
                              //         decoration: BoxDecoration(
                              //           color: Color(0x3300599A),
                              //           borderRadius: BorderRadius.circular(4),
                              //         ),
                                     
                              //       ),
                              //     ),
                               
                              //   ),
                              // ),
                               DataCell(
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    e.AssetName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    e.Supplier,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  child: Text(
                                    e.Location,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SvgPicture.asset(
                                  "assets/images/Select_arrow.svg",
                                  width: 12,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Color(0xffD9D9D9),
                      indent: 24,
                      endIndent: 24,
                    ),
                    Container(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Positioned(
                            child: Row(
                              spacing: 10,
                              children: [
                                Text(
                                  "show",
                                  style: TextStyle(
                                    color: Color(0xff000000),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text("10"),
                                Text(
                                  "entries",
                                  style: TextStyle(
                                    color: Color(0xff000000),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: FooterWidget(),
          )
          ],
        ),
      ),
    );
  }
}
