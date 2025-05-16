import 'package:flutter/material.dart';
import 'package:lmm_user/resource/app_colors.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: const [
                Tab(text: 'SCHEDULED'),
                Tab(text: 'CANCELLED'),
                Tab(text: 'ONBOARDED'),
                Tab(text: 'COMPLETED'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade400,
              indicator: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildVehicleCard(),
          const SizedBox(height: 12),
          _buildContactCard(name: "Manish Mani", icon: Icons.call),
          const SizedBox(height: 12),
          _buildContactCard(name: "Manish Mani", icon: Icons.chat),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sector 1 Noida TO Sector 2 Noida',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Sat, 12 Apr 2025'),
                Text(
                  'SCHEDULED',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Text('Vehicle No : ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('1234dsgj', style: TextStyle(color: Colors.blue)),
              ],
            ),
            Row(
              children: const [
                Text('Vehicle Name : ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Aura', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton('Track', color: Colors.blue),
                const SizedBox(width: 8),
                _actionButton('Cancel', color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: isExpanded!=true,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isExpanded=true;
                  });
                },
                child: const Center(
                  child: Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ),
            Visibility(
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
                        children: const [
                          Text(
                            "10:40 PM",
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
                                "00:05 hr",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            "10:45 PM",
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
                    buildDetailRow("Seat No", "[C1]"),
                    buildDetailRow("Passenger", "1"),
                    buildDetailRow("PNR No", "170510"),
                    buildDetailRow("Total Fare", "₹30"),
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
                            isExpanded=false;
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

  Widget _buildContactCard({required String name, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E7BA6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black),
          )
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
