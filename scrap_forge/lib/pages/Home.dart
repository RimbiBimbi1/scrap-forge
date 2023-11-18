import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/widgets/custom_tile.dart';
import 'package:scrap_forge/widgets/home_section.dart';
import 'package:scrap_forge/widgets/project_strip.dart';
import 'package:scrap_forge/widgets/custom_grid_tile.dart';

// import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  final ThemeData themeData;

  Home({super.key, required this.themeData});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbService = IsarService();
  List<Product> recentlyViewed = List.generate(3, (index) => Product());

  // Future<void> requestAccess() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.camera,
  //     Permission.manageExternalStorage,
  //   ].request();
  //   if (statuses.entries.)
  // }

  // @override
  // void initState() {
  //   requestAccess();
  //   super.initState();
  // }
  Future<void> getRecentProjects() async {
    List<Product> projects = await dbService.getAllProducts();

    setState(() {
      recentlyViewed = projects;
    });
  }

  @override
  void initState() {
    getRecentProjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text("Moja kuźnia"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // child: Image(image: AssetImage('assets/40.jpg')),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...recentlyViewed
                        .map((e) => ProjectStrip(product: e))
                        .toList()
                  ],
                ),
                HomeSection(
                  header: const Text(
                    "Projekty",
                    style: TextStyle(
                      color: Colors.red,
                      letterSpacing: 0.5,
                    ),
                    textScaleFactor: 1.2,
                  ),
                  children: [
                    CustomTile(
                      onPressed: () {},
                      background: Colors.grey[800],
                      color: Colors.white,
                      title: "Ukończone",
                      child: SvgPicture.asset(
                        'assets/image-placeholder.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    CustomTile(
                      onPressed: () {},
                      background: Colors.grey[700],
                      color: Colors.white,
                      title: "W trakcie realizacji",
                      child: SvgPicture.asset(
                        'assets/image-placeholder.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    CustomTile(
                      onPressed: () {},
                      background: Colors.grey[800],
                      color: Colors.white,
                      title: "Planowane",
                      child: SvgPicture.asset(
                        'assets/image-placeholder.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
                HomeSection(
                  header: const Text(
                    "Materiały",
                    style: TextStyle(
                      color: Colors.red,
                      letterSpacing: 0.5,
                    ),
                    textScaleFactor: 1.2,
                  ),
                  children: [
                    CustomTile(
                      onPressed: () {},
                      background: Colors.grey[800],
                      color: Colors.white,
                      title: "Już wykorzystane",
                      child: SvgPicture.asset(
                        'assets/image-placeholder.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    CustomTile(
                      onPressed: () {},
                      background: Colors.grey[700],
                      color: Colors.white,
                      title: "Gotowe do użycia",
                      child: SvgPicture.asset(
                        'assets/image-placeholder.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    CustomTile(
                      onPressed: () {},
                      background: Colors.grey[800],
                      color: Colors.white,
                      title: "Brakujące",
                      child: SvgPicture.asset(
                        'assets/image-placeholder.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),

                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Padding(
                //       padding:
                //           EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                //       child: Text(
                //         "Projekty",
                //         textScaleFactor: 1.2,
                //       ),
                //     ),
                //     Row(
                //       children: [
                //         CustomTile(
                //           onPressed: () {},
                //           background: Colors.grey[800],
                //           color: Colors.white,
                //           title: "Ukończone",
                //           child: SvgPicture.asset(
                //             'assets/image-placeholder.svg',
                //             fit: BoxFit.fill,
                //           ),
                //         ),
                //         const Spacer(
                //           flex: 1,
                //         ),
                //         CustomTile(
                //           onPressed: () {},
                //           background: Colors.grey[800],
                //           color: Colors.white,
                //           title: "W trakcie realizacji",
                //           child: SvgPicture.asset(
                //             'assets/image-placeholder.svg',
                //             fit: BoxFit.fill,
                //           ),
                //         ),
                //         const Spacer(
                //           flex: 1,
                //         ),
                //         CustomTile(
                //           onPressed: () {},
                //           background: Colors.grey[800],
                //           color: Colors.white,
                //           title: "Planowane",
                //           child: SvgPicture.asset(
                //             'assets/image-placeholder.svg',
                //             fit: BoxFit.fill,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Padding(
                //       padding:
                //           EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                //       child: Text(
                //         "Materiały",
                //         textScaleFactor: 1.2,
                //       ),
                //     ),
                //     Row(
                //       children: [],
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: BottomAppBar(
        //   color: Colors.grey[900],
        //   // elevation: 1.0,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //       children: [
        //         IconButton(
        //           onPressed: () {},
        //           icon: const Icon(Icons.menu),
        //           color: Colors.white,
        //           iconSize: 30.0,
        //         ),
        //         IconButton(
        //           onPressed: () {},
        //           icon: const Icon(Icons.account_circle_sharp),
        //           color: Colors.white,
        //           iconSize: 30.0,
        //         ),
        //         IconButton(
        //           onPressed: () {},
        //           icon: const Icon(Icons.add),
        //           color: Colors.white,
        //           iconSize: 30.0,
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
