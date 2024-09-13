import 'package:babel_novel/providers/current_chapter_provider.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:babel_novel/providers/novel_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_novel/providers/preference_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NovelViewOptionPanel extends ConsumerStatefulWidget {
  const NovelViewOptionPanel({super.key});

  @override
  _NovelViewOptionPanelState createState() => _NovelViewOptionPanelState();
}

class _NovelViewOptionPanelState extends ConsumerState<NovelViewOptionPanel> {
  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferenceProvider);
    final novelDetails = ref.watch(currentNovelProvider);
    final regExp = RegExp(r'\d+');
    return Material(
      elevation: 5, // Increase the elevation for a more pronounced shadow
      // shadowColor: Colors.black.withOpacity(0.5),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      clipBehavior: Clip.hardEdge,
      surfaceTintColor: Theme.of(context).colorScheme.primary,
      child: Container(
        // color: Theme.of(context).colorScheme.primary,
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
                          vertical: 10,
                        ),
                        minimumSize:
                            const Size(40, 20), // Adjust the minimum size

                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
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
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Scroll View',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      preferences.scrollDirection == ScrollDirection.vertical
                          ? 'Scroll'
                          : 'Page',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        preferences.setScrollDirection(
                          preferences.scrollDirection ==
                                  ScrollDirection.vertical
                              ? ScrollDirection.horizontal
                              : ScrollDirection.vertical,
                        );
                      },
                      child: SvgPicture.asset(
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).textTheme.bodyMedium!.color!,
                            BlendMode.srcIn),
                        preferences.scrollDirection == ScrollDirection.vertical
                            ? 'assets/svgs/horizontal_scroll.svg'
                            : 'assets/svgs/vertical_scroll.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${regExp.firstMatch(novelDetails?.currentChapterId.split("/").last ?? "0")!.group(0)} / ${ref.read(totalNovelPages)} ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
