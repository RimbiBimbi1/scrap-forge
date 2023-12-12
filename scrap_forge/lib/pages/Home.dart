import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/widgets/custom_tile.dart';
import 'package:scrap_forge/widgets/home_section.dart';
import 'package:scrap_forge/widgets/recent_strip.dart';

// import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  // final ThemeData themeData;

  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbService = IsarService();

  List<Product> recentlyViewed = List.empty();

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
    List<Product> projects = await dbService.getNewestProducts(3);

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
    ThemeData theme = Theme.of(context);

    return Scaffold(
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
          child: ListView(
            // child: Image(image: AssetImage('assets/40.jpg')),
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...recentlyViewed.map((e) => RecentStrip(product: e)).toList()
                ],
              ),
              HomeSection(
                header: Text(
                  "Projekty",
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                  ),
                  textScaleFactor: 1.2,
                ),
                children: [
                  CustomTile(
                    onPressed: () {
                      Navigator.pushNamed(context, "/products", arguments: {
                        "productFilter": ProductFilter.finishedProducts()
                      });
                    },
                    background: theme.colorScheme.secondary,
                    color: theme.colorScheme.onSecondary,
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
                    onPressed: () {
                      Navigator.pushNamed(context, "/products", arguments: {
                        "productFilter": ProductFilter.inProgressProducts()
                      });
                    },
                    background: theme.colorScheme.secondary,
                    color: theme.colorScheme.onSecondary,
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
                    onPressed: () {
                      Navigator.pushNamed(context, "/products", arguments: {
                        "productFilter": ProductFilter.plannedProducts()
                      });
                    },
                    background: theme.colorScheme.secondary,
                    color: theme.colorScheme.onSecondary,
                    title: "Planowane",
                    child: SvgPicture.asset(
                      'assets/image-placeholder.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
              HomeSection(
                header: Text(
                  "Materiały",
                  textScaleFactor: 1.2,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                children: [
                  CustomTile(
                    onPressed: () {
                      Navigator.pushNamed(context, "/products", arguments: {
                        "productFilter": ProductFilter.consumedMaterials()
                      });
                    },
                    background: theme.colorScheme.secondary,
                    color: theme.colorScheme.onSecondary,
                    title: "Już użyte",
                    child: SvgPicture.asset(
                      'assets/image-placeholder.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  CustomTile(
                    onPressed: () {
                      Navigator.pushNamed(context, "/products", arguments: {
                        "productFilter": ProductFilter.availableMaterials()
                      });
                    },
                    background: theme.colorScheme.secondary,
                    color: theme.colorScheme.onSecondary,
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
                    onPressed: () {
                      Navigator.pushNamed(context, "/products", arguments: {
                        "productFilter": ProductFilter.neededMaterials()
                      });
                    },
                    background: theme.colorScheme.secondary,
                    color: theme.colorScheme.onSecondary,
                    title: "Brakujące",
                    child: SvgPicture.asset(
                      'assets/image-placeholder.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/editProduct");
                },
                child: Text(
                  "+",
                  textScaleFactor: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
