import 'package:flutter/material.dart';
import 'package:lmm_user/resource/image_paths.dart';
import 'package:lmm_user/ui/explore_routes/stops_dialog.dart';
import 'package:provider/provider.dart';

import '../../provider/route_explore_provider.dart';
import '../../resource/Utils.dart';

class ExploreRoutes extends StatefulWidget {
  @override
  _ExploreRoutesState createState() => _ExploreRoutesState();
}

class _ExploreRoutesState extends State<ExploreRoutes> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RouteExploreProvider>(context, listen: false).fetchRouteExplore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          "Explore Routes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF023E8A),
      ),
      body: Consumer<RouteExploreProvider>(
        builder: (context, provider, _) {
          if (provider.routeExploreData.isEmpty) {
            return Center(child: Utils.buildLoader());
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: provider.routeExploreData.length,
              itemBuilder: (context, index) {
                return InkWell(onTap: (){
                  showDialog(
                    context: context,
                    builder: (context) => StopsDialog(provider.routeExploreData[index]['stops'],provider.routeExploreData[index]['route_title']),
                  );
                },
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Image.asset(
                            ImagePaths.routes,
                            width: 40,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              provider.routeExploreData[index]['route_title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            size: 24,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            );
          }
        },
      )
    );
  }
}