import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/utils/product_list_comparator.dart';
import 'package:scrap_forge/widgets/custom_tile.dart';
import 'package:scrap_forge/widgets/home_section.dart';
import 'package:scrap_forge/widgets/product_strip_small.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final IsarService db = IsarService();

  List<Product> recentlyViewed = List.empty();

  Future<void> getRecentProjects() async {
    List<Product> projects = await db.getNewestProducts(3);

    if (!ProductListComparator.compareByLastModifiedTimestamps(
        recentlyViewed, projects)) {
      setState(() {
        recentlyViewed = projects;
      });
    }
  }

  @override
  void initState() {
    getRecentProjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ThemeData theme = Theme.of(context);

    db.listenToProducts().listen((event) {
      if (mounted) getRecentProjects();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text("Moja kuźnia"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: const Icon(Icons.settings))
        ],
        centerTitle: true,
      ),
      floatingActionButton: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                onPressed: () {
                  Navigator.pushNamed(context, "/measure",
                      arguments: {'onBoundingBoxConfirmed': (values) {}});
                },
                child: const Icon(
                  Icons.straighten,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                onPressed: () {
                  Navigator.pushNamed(context, "/editProduct");
                },
                child: const Icon(
                  Icons.add_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Text(
                'Ostatnio edytowane',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                ),
                textScaleFactor: 1.2,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...recentlyViewed
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: ProductStripSmall(
                              key: GlobalKey(),
                              product: e,
                            ),
                          ))
                      .toList()
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
                    child: const Image(
                      image: AssetImage('assets/images/anvil.png'),
                      fit: BoxFit.fitWidth,
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
                    child: const Image(
                      image: AssetImage('assets/images/planned_projects.png'),
                      fit: BoxFit.fitHeight,
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
                    child: const Image(
                      image: AssetImage('assets/images/rack.png'),
                      fit: BoxFit.fitHeight,
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
                    child: const Image(
                      image: AssetImage('assets/images/needed_materials.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}
