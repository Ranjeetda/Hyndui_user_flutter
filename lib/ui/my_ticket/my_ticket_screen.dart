import 'package:flutter/material.dart';
import 'package:lmm_user/resource/app_colors.dart';
import 'package:lmm_user/resource/image_paths.dart';
import 'package:provider/provider.dart';

import '../../provider/mytripes_provider.dart';
import '../../resource/CustomTabIndicator.dart';
import '../../resource/Utils.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late TabController _tabController;
  var offSet = 0;
  String selectedTabText = 'SCHEDULED';
  var limit = 10;
  final List<String> tabLabels = [
    'SCHEDULED',
    'CANCELLED',
    'ONBOARDED',
    'COMPLETED',
    'EXPIRED'
  ];

  @override
  void initState() {
    super.initState();

    Provider.of<MytripesProvider>(context, listen: false).loadMyTripsService(
        offSet.toString(), limit.toString(), selectedTabText);

    _tabController = TabController(length: tabLabels.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          selectedTabText = tabLabels[_tabController.index];
        });
        print('Selected tab: $selectedTabText');
        Provider.of<MytripesProvider>(context, listen: false)
            .loadMyTripsService(
                offSet.toString(), limit.toString(), selectedTabText);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: tabLabels.map((text) => Tab(text: text)).toList(),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: Color(0xFF007EA7), // your selected tab color (blue)
                    borderRadius: BorderRadius.circular(32),
                  ),
                  indicatorPadding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 24),
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: List.generate(4, (index) => _buildScheduledTab()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledTab() {
    return Consumer<MytripesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: Utils.buildLoader());
        }else if (provider.myTripsListData.isEmpty) {
          return Center(child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  ImagePaths.appLogo, // Put your logo in assets/images/
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                // Text
                Text(
                  "No Data Available",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),);
        } else {
          return _buildVehicleCard(provider.myTripsListData);
        }
      },
    );
  }

  Widget _buildVehicleCard(List <dynamic> myTripsListData) {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: myTripsListData.length,
        itemBuilder: (context, index) {
          return InkWell(onTap: (){
          },
            child:  Column(
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${myTripsListData[index]['pickup_name'] ?? ''} ${myTripsListData[index]['drop_name'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:  [
                            Text(Utils.convertDateToBeautifyString(myTripsListData[index]['start_date'])),
                            Text(
                              myTripsListData[index]['travel_status'],
                              style: TextStyle(
                                  color: selectedTabText=='SCHEDULED'?Colors.green:selectedTabText=='ONBOARDED'?Colors.green:selectedTabText=='EXPIRED'?Colors.red:selectedTabText=='CANCELLED'?Colors.red:Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children:  [
                            Text('Vehicle No : ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(myTripsListData[index]['bus_model_no'], style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                        Row(
                          children:  [
                            Text('Vehicle Name : ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(myTripsListData[index]['bus_name'], style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        selectedTabText=='SCHEDULED'?Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _actionButton('Track', color: Colors.blue),
                            const SizedBox(width: 8),
                            _actionButton('Cancel', color: Colors.red),
                          ],
                        ):SizedBox(),
                        const SizedBox(height: 8),
                        selectedTabText=='CANCELLED'?SizedBox(): selectedTabText=='EXPIRED'?SizedBox():Visibility(
                          visible: isExpanded != true,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isExpanded = true;
                              });
                            },
                            child: const Center(
                              child: Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ),
                        selectedTabText=='CANCELLED'?SizedBox(): selectedTabText=='EXPIRED'?SizedBox():Visibility(
                          visible: isExpanded,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Time and bus icon row
                                Container(
                                  color: Color(0xFFF5F5F5), // Light gray background
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:  [
                                      Text(
                                        myTripsListData[
                                        index]['start_time'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Icon(Icons.directions_bus,
                                              size: 28, color: Colors.blue),
                                          SizedBox(height: 4),
                                          Text(
                                            Utils.diffTime(myTripsListData[
                                            index]['start_time'],myTripsListData[
                                            index]['drop_time']

                                            ),
                                            style:
                                            TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        myTripsListData[
                                        index]['drop_time'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Trip details
                                buildDetailRow("Seat No", "[${myTripsListData[index]['seat_nos'][0]}]"),
                                buildDetailRow("Passenger", myTripsListData[index]['passengers']),
                                buildDetailRow("PNR No", myTripsListData[index]['pnr_no']),
                                buildDetailRow("Total Fare", "₹${myTripsListData[index]['final_total_fare']}"),
                                const SizedBox(height: 8),

                                const Text(
                                  "You can download invoice after trip is completed.",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Visibility(
                                  visible: isExpanded,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isExpanded = false;
                                      });
                                    },
                                    child: const Center(
                                      child: Icon(Icons.keyboard_arrow_up),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                selectedTabText=='SCHEDULED'?const SizedBox(height: 12):selectedTabText=='ONBOARDED'?const SizedBox(height: 12):SizedBox(),
                selectedTabText=='SCHEDULED'? _buildContactCard(name: myTripsListData[index]['booking_assign']['driver_fullname'], icon1: Icons.chat,icon: Icons.call):selectedTabText=='ONBOARDED'? _buildContactCard(name: myTripsListData[index]['booking_assign']['driver_fullname'],icon1: Icons.chat, icon: Icons.call):SizedBox(),
                selectedTabText=='SCHEDULED'?const SizedBox(height: 12):selectedTabText=='ONBOARDED'?const SizedBox(height: 12):SizedBox(),
              ],),
          );
        },
      ),
    );
  }

  static Widget _actionButton(String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }

  Widget _buildContactCard({required String name, required IconData icon1,required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E7BA6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            height: 32,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon1, color: Colors.black, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            height: 32,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
