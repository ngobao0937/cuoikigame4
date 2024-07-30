import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'GridList.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _textController;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GridList()),
        );
      }
    });

    _textController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 107, 159, 248),
      body: Stack(
        children: [
          Center(
            child: LottieBuilder.asset(
              "assets/lotties/Animation - 1722057660598.json",
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
                _lottieController.forward();
              },
            ),
          ),
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: _textAnimation,
                child: Text(
                  "Welcom to Scanner",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
