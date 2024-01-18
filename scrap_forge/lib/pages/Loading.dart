import 'package:flutter/material.dart';
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
    ThemeData theme = Theme.of(context);

    return Container(
      color: const Color.fromARGB(180, 33, 33, 33),
      child: Center(
        // child: SpinKitFadingCircle(
        //   color: Colors.orange,
        //   size: 100.0,
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AspectRatio(
              aspectRatio: 1,
              child: RiveAnimation.asset('assets/hearth2.riv'),
            ),
            Text(
              'Ładowanie...',
              style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 25,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
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
