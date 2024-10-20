import 'dart:async';

import 'package:dio/dio.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:babel_novel/hive_adapters/chapter_list_item.dart';
import 'package:babel_novel/hive_adapters/current_novel.dart';
import 'package:babel_novel/providers/current_novel_provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'env.dart';
import 'firebase_options.dart';
import 'utils/http_client.dart';

void main() async {
  await runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      // Retain native splash screen until Dart is ready
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      GetIt.instance.registerLazySingleton(
        () {
          return HttpClient(baseOptions: BaseOptions(baseUrl: Env.hostedUrl));
        },
      );
      if (!kIsWeb) {
        if (kDebugMode) {
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(false);
        } else {
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(false);
        }
      }
      if (kDebugMode) {
        await FirebasePerformance.instance
            .setPerformanceCollectionEnabled(false);
      }
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      ErrorWidget.builder = (FlutterErrorDetails error) {
        Zone.current.handleUncaughtError(error.exception, error.stack!);
        return ErrorWidget(error.exception);
      };
      // Hive Database
      await Hive.initFlutter();
      Hive
        ..registerAdapter(CurrentNovelAdapter())
        ..registerAdapter(ChapterListItemAdapter());
      if (!Hive.isBoxOpen(Env.novel_db_name)) {
        final box = await Hive.openBox<CurrentNovel>(Env.novel_db_name);
      }
      await Hive.openBox<CurrentNovel>(Env.shelf_db_name);
      await Hive.openBox<CurrentNovel>(Env.viewed_db_name);

      final currentNovelNotifier = await loadCurrentNovel();

      runApp(
        ProviderScope(
          overrides: [
            currentNovelProvider.overrideWith((ref) {
              return currentNovelNotifier;
            }),
          ],
          child: RefreshConfiguration(
            child: BetterFeedback(
                theme: FeedbackThemeData(
                  feedbackSheetColor: Colors.grey[50]!,
                  drawColors: [
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.yellow,
                  ],
                ),
                darkTheme: FeedbackThemeData.dark(),
                localizationsDelegates: [
                  GlobalFeedbackLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                localeOverride: const Locale('en'),
                pixelRatio: 1,
                child: const MyApp()),
          ),
        ),
      );
      FlutterNativeSplash.remove(); // Now remove splash screen
    },
    (exception, stackTrace) {
      FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    },
  );
}

Future<CurrentNovelNotifier> loadCurrentNovel() async {
  final novelBox = Hive.box<CurrentNovel>(Env.shelf_db_name);
  final currentNovelBox = Hive.box<CurrentNovel>(Env.novel_db_name);
  final currentNovel = currentNovelBox.get('currentNovel');
  print('This is currentNovel: ${currentNovel?.novelTitle}');
  final notifier = CurrentNovelNotifier();
  if (currentNovel != null) {
    notifier.setNovel(currentNovel);
  }
  return notifier;
}
