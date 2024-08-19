import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_novel/providers/feedback_provider.dart';
import 'package:babel_novel/providers/setting_option_provider.dart';
import 'package:babel_novel/utils/theme_colors.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackState = ref.watch(feedbackProvider);
    final settingOpt = ref.watch(settingsOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback Mode',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Let us know what you think about the application.',
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(feedbackProvider.notifier).state = !feedbackState;
              },
              child: Text(feedbackState ? 'Turn Off' : 'Turn On'),
            )
          ]),
          const SizedBox(
            height: 20,
          ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Dark Mode',
          //             style: Theme.of(context)
          //                 .textTheme
          //                 .bodyLarge
          //                 ?.copyWith(fontWeight: FontWeight.w600),
          //           ),
          //           const SizedBox(height: 5),
          //           const Text(
          //             'Switch between the light and dark mode.',
          //           )
          //         ],
          //       ),
          //     ),
          //     Switch(
          //       // value: settingOpt.darkMode,
          //       value: settingOpt.darkMode,
          //       onChanged: (val) {
          //         if (val == true) {}
          //         ref
          //             .read(settingsOptionsProvider.notifier)
          //             .updateDarkMode(val);
          //       },
          //       activeTrackColor: ThemeColors.limeGreen,
          //       inactiveTrackColor: Colors.grey,
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }
}
