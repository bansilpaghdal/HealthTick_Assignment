import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/scheduler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Center(
              child: Text('Mindful Meal Eater'),
            )),
        backgroundColor: Colors.white, // Match the background color
        body: Center(
          child: StopwatchWidget(),
        ),
      ),
    );
  }
}

class StopwatchWidget extends StatefulWidget {
  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? timer;
  bool isSoundOn = true;
  late AudioPlayer audioPlayer;
  bool shouldPlaySound = false;
  bool showfullbutton = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );

    audioPlayer = AudioPlayer();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();

        print('one round over');

        setState(() {
          _currentPage = (_currentPage + 1) % 3;
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        });
      }
    });

    // controller.addListener(() {
    //   if ((controller.duration! * controller.value).inSeconds > 25 &&
    //       !shouldPlaySound) {
    //     shouldPlaySound = true;
    //     playTickSound();
    //   }
    //   if (controller.value > 0.166 && shouldPlaySound) {
    //     shouldPlaySound = false;
    //   }
    // });

    startTimer();
  }

  void playTickSound() async {
    // audioPlayer.setReleaseMode(ReleaseMode.loop);

    // audioPlayer.play(AssetSource('countdown_tick.mp3'));
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (!controller.isAnimating) {
        t.cancel();
      } else {
        setState(() {});
      }
    });
  }

  String getRemainingTime() {
    Duration duration = controller.duration! * controller.value;
    int seconds = 30 - duration.inSeconds;

    return '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    super.dispose();
    audioPlayer.dispose();
  }

  void pauseResumeTimer() {
    if (controller.isAnimating) {
      controller.stop();
      timer?.cancel();
    } else {
      startTimer();
      controller.forward(from: controller.value);
    }

    setState(() {
      showfullbutton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: [
              CarouselWithIndicator(
                pageController: _pageController,
              ),
              CustomPaint(
                painter: TimerPainter(
                  animation: controller,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                size: Size(20, 20),
                child: Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '00 :  ${getRemainingTime()}',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'minutes remaining',
                        style: TextStyle(fontSize: 15, color: Colors.black45),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Switch(
                value: isSoundOn,
                onChanged: (value) {
                  setState(() {
                    isSoundOn = value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
              Text(
                isSoundOn ? 'Sound On' : 'Sound Off',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: pauseResumeTimer,
            child: Text(
              controller.isAnimating ? 'PAUSE' : 'START',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 173, 229, 176),
              foregroundColor: Colors.black,
              elevation: 8, // Elevation
              shadowColor: Colors.teal[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 120, vertical: 20),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          showfullbutton == false
              ? SizedBox()
              : TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side:
                          BorderSide(color: Colors.blueGrey.shade700, width: 2),
                    ),
                  ),
                  child: const Text(
                    "LET'S STOP I'M FULL NOW",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final int totalSeconds = 60;
    final double oneSecAngle = 2 * 3.1415926535897932 / totalSeconds;

    final double normalMarkLength = 12.0;
    final double quarterMarkLength = 18.0;

    final double radius = size.width / 2;
    final double quarterMarkRadius = radius - quarterMarkLength;
    final double normalMarkRadius = radius - normalMarkLength;

    for (int i = 0; i < totalSeconds; i++) {
      final double angle = i * oneSecAngle - 3.1415926535897932 / 2;
      final bool isQuarterMark = i % (totalSeconds / 4) == 0;
      final double markRadius =
          isQuarterMark ? quarterMarkRadius : normalMarkRadius;

      final Offset start = size.center(Offset.zero) +
          Offset(cos(angle), sin(angle)) * markRadius;
      final double markLength =
          isQuarterMark ? quarterMarkLength : normalMarkLength;
      final Offset end = start + Offset(cos(angle), sin(angle)) * markLength;

      paint.color =
          (i < totalSeconds * animation.value) ? backgroundColor : color;
      canvas.drawLine(start, end, paint);
    }

    paint..strokeWidth = 8;

    paint.color = Colors.white;
    canvas.drawArc(Offset.zero & size, -3.1415926535897932 / 2,
        2 * 3.1415926535897932, false, paint);

    // Draw the remaining time in green
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * 3.1415926535897932;
    canvas.drawArc(
        Offset.zero & size, -3.1415926535897932 / 2, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}

class CarouselWithIndicator extends StatefulWidget {
  PageController pageController;

  CarouselWithIndicator({required this.pageController});
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  @override
  int currentPage = 0;

  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      int next = widget.pageController.page!.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  Widget _buildDot(int index) {
    return Container(
      height: currentPage == index ? 14 : 10,
      width: currentPage == index ? 14 : 10,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentPage == index ? Colors.black : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 15), // For spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(3, _buildDot),
          ),
          // For spacing
          Container(
            height: 150, // Adjust the height as needed
            child: PageView(
              controller: widget.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Nom nom :)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'You have 10 minutes to eat before the pause.\nFocus on eating slowly',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Break Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Take a five minute break to check in in your level of fulness',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Finish Your Meal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'You can eat until you feel full',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.pageController.dispose();
    super.dispose();
  }
}
