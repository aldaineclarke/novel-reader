import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_novel/providers/preference_provider.dart';

class NovelViewOptionPanel extends ConsumerStatefulWidget {
  const NovelViewOptionPanel({super.key});

  @override
  _NovelViewOptionPanelState createState() => _NovelViewOptionPanelState();
}

class _NovelViewOptionPanelState extends ConsumerState<NovelViewOptionPanel> {
  double _currentSliderValue = 0.7;
  static const brightnessChannel = MethodChannel('brightnessPlatform');

  Future<void> _setBrightness(double brightness) async {
    try {
      print('BrightNess: $brightness');
      await brightnessChannel
          .invokeMethod('setBrightness', {'brightness': brightness});
    } on PlatformException catch (e) {
      print("Failed to set brightness: '${e}'.");
    }
  }

  Future<void> _getBrightness() async {
    try {
      final brightessVal =
          await brightnessChannel.invokeMethod('getBrightness');
    } on PlatformException catch (e) {
      print("Failed to set brightness: '${e}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferenceProvider);
    return Material(
      elevation: 9,
      shadowColor: Colors.black,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      clipBehavior: Clip.hardEdge,
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Text(
              'Brightness',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                const Icon(
                  Icons.brightness_1,
                  size: 8,
                ),
                Expanded(
                  child: SliderTheme(
                    data: const SliderThemeData(trackHeight: 1),
                    child: Slider(
                      divisions: 100,
                      min: 0,
                      max: 1,
                      value: _currentSliderValue,
                      onChanged: (value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                      onChangeEnd: _setBrightness,
                    ),
                  ),
                ),
                const Icon(Icons.brightness_high, size: 16)
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Page Themes',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          minimumSize:
                              const Size(40, 20), // Adjust the minimum size

                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {
                        preferences
                          ..setBackgroundColor(Colors.white)
                          ..setFontColor(Colors.black87);
                      },
                      child: const Text(
                        'Blanc',
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFf8fd98),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        minimumSize:
                            const Size(40, 20), // Adjust the minimum size

                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onPressed: () {
                      preferences
                        ..setBackgroundColor(const Color(0xFFf8fd98))
                        ..setFontColor(Colors.black87);
                    },
                    child: const Text(
                      'Sunlit',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          minimumSize:
                              const Size(40, 20), // Adjust the minimum size

                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {
                        preferences
                          ..setBackgroundColor(Colors.black54)
                          ..setFontColor(Colors.white70);
                      },
                      child: const Text(
                        'Dark Light',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEDD1B0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          minimumSize:
                              const Size(40, 20), // Adjust the minimum size

                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {
                        preferences
                          ..setBackgroundColor(const Color(0xFFEDD1B0))
                          ..setFontColor(Colors.brown[900]!);
                      },
                      child: const Text(
                        'Vintage',
                        style: TextStyle(color: Colors.brown),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Font Size',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          preferences.setFontSize(preferences.fontSize - 1);
                        },
                        child: const Text(
                          'A-',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(width: 10),
                    Text('${preferences.fontSize.toInt()}pt'),
                    const SizedBox(width: 10),
                    InkWell(
                        onTap: () {
                          preferences.setFontSize(preferences.fontSize + 1);
                        },
                        child: const Text(
                          'A+',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
