import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:missiontimer/WaterEffect.dart';

void main() {
  runApp(MissionTimerApp());
}

class MissionTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterWebFrame(
      builder: (Context) {
        return MaterialApp(
          title: 'Mission Timer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: PomodoroTimer(),
        );
      },
      maximumSize: Size(475.0, 612.0),
      enabled: kIsWeb, // default is enable, when disable content is full size
      backgroundColor: Colors.black, // Background color/white space
    );
  }
}

class PomodoroTimer extends StatefulWidget {
  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

// timer item 선택
enum TimeLabel {
  five('5분', 5),
  ten('10분', 10),
  fifteen('15분', 15),
  twenty('20분', 20),
  twentyfive('25분', 25),
  fourtyfive('45분', 45),
  sixty('60분', 60);

  const TimeLabel(this.label, this.min);
  final String label;
  final int min;
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  int _minutes = TimeLabel.five.min; // 일단 5분으로 초기화
  int _seconds = 0;
  double _progressValue = 1.0;
  bool _isActive = false;
  late Timer _timer;

  TimeLabel? selectedTime = TimeLabel.five;
  String makeStringMinutes() {
    return (_minutes < 10) ? '0$_minutes' : '$_minutes';
  }

  String makeStringSeconds() {
    return (_seconds < 10) ? '0$_seconds' : '$_seconds';
  }

  void startTimer() {
    _isActive = true;
    _progressValue = 1.0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds == 0) {
          if (_minutes == 0) {
            _isActive = false;
            _timer.cancel();

            // 선택내용 초기화
            _minutes = selectedTime!.min;
          } else {
            _minutes--;
            _seconds = 59;
          }
        } else {
          _seconds--;
          _progressValue =
              (_minutes * 60 + _seconds) / (selectedTime!.min * 60);
        }
      });
    });
  }

  void resetTimer() {
    _timer.cancel();
    setState(() {
      _minutes = selectedTime!.min;
      _seconds = 0;
      _progressValue = 1.0;
      _isActive = false;
    });
  }

  void setTimer(int minutes) {
    if (!_isActive) {
      setState(() {
        _minutes = minutes;
        _seconds = 0;
        _progressValue = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = makeStringMinutes();
    String secondsStr = makeStringSeconds();

    final TextEditingController colorController = TextEditingController();

    return Scaffold(
      appBar: EmptyAppBar(),
      body: WaterEffect(
        alpha: 0.3,
        colorIndx: 2,
        backWidget: Container(
          child: makeBackground(_isActive),
        ),
        frontWidget: Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$minutesStr:$secondsStr',
                  style: TextStyle(color: Colors.green, fontSize: 60),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: _progressValue,
                    strokeWidth: 10,
                    backgroundColor: Colors.green,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isActive
                          ? Colors.black
                          : Color.fromARGB(50, 100, 100, 100),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        if (!_isActive) {
                          startTimer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Start'),
                    ),
                    ElevatedButton(
                      onPressed: resetTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Reset'),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                DropdownMenu<TimeLabel>(
                  initialSelection: TimeLabel.five,
                  controller: colorController,
                  requestFocusOnTap: true,
                  label: const Text('시간선택'),
                  onSelected: (TimeLabel? time) {
                    setState(() {
                      selectedTime = time;
                      _minutes = selectedTime!.min;
                      minutesStr = makeStringMinutes();
                      secondsStr = makeStringSeconds();
                    });
                  },
                  dropdownMenuEntries: TimeLabel.values
                      .map<DropdownMenuEntry<TimeLabel>>((TimeLabel color) {
                    return DropdownMenuEntry<TimeLabel>(
                      value: color,
                      label: color.label,
                      style: MenuItemButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget makeBackground(bool isActive) {
    if (!isActive) {
      return Container();
    } else {
      var src =
          "https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExbm9oYTN6OGR3aHB0dTN2cmV3M21ma25sYzE2ZmtubjJnOHl3bDhtaCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/13sozYO4hmSMUw/giphy.gif";
      return Image.network(
        src,
        color: Colors.white.withOpacity(0.3),
        colorBlendMode: BlendMode.modulate,
        width: double.infinity,
        fit: BoxFit.fill,
      );
    }
  }
}

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}
