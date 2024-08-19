import 'dart:io';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_novel/env.dart';
import 'package:babel_novel/main_scaffold.dart';
import 'package:babel_novel/providers/feedback_provider.dart';
import 'package:babel_novel/providers/setting_option_provider.dart';
import 'package:babel_novel/utils/book_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Future<void> feedback(BuildContext context) async {
    BetterFeedback.of(context).show((feedback) async {
      final screenshotFilePath = await writeImageToStorage(feedback.screenshot);
      final email = Email(
        body: feedback.text,
        subject: 'App Feedback',
        recipients: [Env.feedback_recipient],
        attachmentPaths: [screenshotFilePath],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    });
  }

  // Takes in feedbackScreenshot data then creates a directory and file path then creates a file then write the screenshot data to that file
  Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
    final output = await getTemporaryDirectory();
    final screenshotFilePath = '${output.path}/feedback.png';
    final screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  void innitiateSettingsPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('darkMode') ?? false;
    final settingsOpts = SettingsOptions(
      darkMode: isDarkMode,
    );
    ref.read(settingsOptionsProvider.notifier).updateState(settingsOpts);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    innitiateSettingsPreferences();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(feedbackProvider);

    return Scaffold(
      body: MaterialApp(
        title: 'Babel Novel',
        // theme: ref.watch(settingsOptionsProvider).darkMode
        //     ? BookTheme.darkTheme
        //     : BookTheme.lightTheme, // Use the light theme
        theme: BookTheme.lightTheme,
        darkTheme: BookTheme.darkTheme, // Use the dark theme
        debugShowCheckedModeBanner: false,
        home: MainScaffold(),
      ),
      floatingActionButton: feedbackState
          ? FloatingActionButton(
              onPressed: () {
                ref.read(feedbackProvider.notifier).state = !feedbackState;
                feedback(context);
              },
              tooltip: 'Feedback',
              backgroundColor: Colors.amber,
              child: const Icon(
                Icons.add,
                color: Colors.brown,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
