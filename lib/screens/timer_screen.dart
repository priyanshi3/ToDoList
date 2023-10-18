import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widget/shared/RoundButton.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isRainSoundPlaying = false;

  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${controller.duration!.inHours}:${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${count.inHours}:${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double progress = 1.0;

  Future<void> _playRainSound() async {
    if (!isRainSoundPlaying) {
      try {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/rain_sound.mp3');
        final data = await rootBundle.load('assets/rain_sound.mp3');
        await file.writeAsBytes(data.buffer.asUint8List());

        await audioPlayer.play(UrlSource(file.path));
        isRainSoundPlaying = true;
      } catch (e) {
        print(e);
      }
    }
  }

  void _stopRainSound() {
    if (isRainSoundPlaying) {
      audioPlayer.stop();
      isRainSoundPlaying = false;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        hours: 0,
        minutes: 0,
        seconds: 10,
      ),
    );

    controller.addListener(() {
      setState(() {
        progress = controller.value;
      });
    });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          isPlaying = false;
        });
        if (controller.isDismissed) {
          _playRingtone();
          if (controller.duration!.inSeconds > 540) {
            _playRainSound();
          } else {
            _stopRainSound();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRingtone() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ringtone.mp3');
      final data = await rootBundle.load('assets/ringtone.mp3');
      await file.writeAsBytes(data.buffer.asUint8List());

      await audioPlayer.play(UrlSource(file.path));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.isDismissed) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          height: 300,
                          color: Colors.white,
                          child: CupertinoTimerPicker(
                            initialTimerDuration: controller.duration!,
                            onTimerDurationChanged: (time) {
                              setState(() {
                                controller.duration = time;
                              });
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return Text(
                        countText,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (controller.isAnimating) {
                              controller.stop();
                              setState(() {
                                isPlaying = false;
                              });
                              _stopRainSound(); // Stop rain sound
                            } else {
                              controller.reverse(
                                  from: controller.value == 0.0
                                      ? 1.0
                                      : controller.value);
                              setState(() {
                                isPlaying = true;
                              });
                              _playRainSound(); // Play rain sound
                            }
                          },
                          child: RoundButton(
                            icon: isPlaying == true
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.reset();
                            setState(() {
                              isPlaying = false;
                            });
                            _stopRainSound(); // Stop rain sound
                          },
                          child: RoundButton(
                            icon: Icons.stop,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
