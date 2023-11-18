import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
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
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      CustomGridTile(
                        onPressed: () => {},
                        title: "Projekty",
                        background: Colors.red[400],
                        child: SvgPicture.asset(
                          'assets/image-placeholder.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      CustomGridTile(
                        onPressed: () => {},
                        title: "Materiały",
                        child: Placeholder(),
                        background: Colors.blueGrey,
                      ),
                    ],
                  ),
                ),
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
