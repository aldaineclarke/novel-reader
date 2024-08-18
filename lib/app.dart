import 'dart:io';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/env.dart';
import 'package:novel_reader/main_scaffold.dart';
import 'package:novel_reader/providers/feedback_provider.dart';
import 'package:novel_reader/utils/book_theme.dart';
import 'package:path_provider/path_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackState = ref.watch(feedbackProvider);

    return Scaffold(
      body: MaterialApp(
        title: 'Novel Reader',
        theme: BookTheme.lightTheme, // Use the light theme
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
