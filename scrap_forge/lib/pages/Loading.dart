import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rive/rive.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(127, 33, 33, 33),
      body: Center(
        // child: SpinKitFadingCircle(
        //   color: Colors.orange,
        //   size: 100.0,
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: RiveAnimation.asset('assets/hearth2.riv'),
            ),
            Text(
              'Ładowanie...',
              style: TextStyle(color: Colors.amber, fontSize: 25, shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 0),
                  blurRadius: 7,
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
