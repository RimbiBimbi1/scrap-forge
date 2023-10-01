import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ScrapForge"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
          centerTitle: true,
          backgroundColor: Colors.grey[900],
        ),
        body: const Column(
          // child: Image(image: AssetImage('assets/40.jpg')),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text("Nowości"), Text('Konkurs'), Text("Polecane")],
        ),
        bottomNavigationBar: BottomAppBar(
            color: Colors.grey[900],
            // elevation: 1.0,
            child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu),
                      color: Colors.white,
                      iconSize: 30.0,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.account_circle_sharp),
                      color: Colors.white,
                      iconSize: 30.0,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                      iconSize: 30.0,
                    ),
                  ],
                ))));
  }
}
