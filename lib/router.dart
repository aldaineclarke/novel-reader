import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterboilerplate/main_scaffold.dart';
import 'package:flutterboilerplate/pages/genres.dart';
import 'package:flutterboilerplate/pages/novel_details.dart';
import 'package:flutterboilerplate/pages/novel_list.dart';
import 'package:go_router/go_router.dart';

import 'pages/home.dart';

GoRouter appRouter() => GoRouter(
      debugLogDiagnostics: kDebugMode,
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          name: HomePage.routeName,
          builder: (BuildContext context, GoRouterState state) =>
              const MainScaffold(child: HomePage()),
        ),
        GoRoute(
          path: '/genres',
          name: GenresPage.routeName,
          builder: (BuildContext context, GoRouterState state) =>
              const MainScaffold(child: GenresPage()),
        ),
        GoRoute(
            path: '/novels/:id',
            name: NovelDetailsPage.routeName,
            builder: (BuildContext context, GoRouterState state) {
              final id = state.pathParameters['id'] ?? '';
              return NovelDetailsPage(novelId: id);
            }),
        GoRoute(
          path: '/novel-list/:id',
          name: NovelListScreen.routeName,
          builder: (BuildContext context, GoRouterState state) {
            final id = state.pathParameters['id'] ?? '';
            return const NovelListScreen(listId: 'latest-release');
          },
        ),
      ],
      observers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      /*refreshListenable: GoRouterRefreshStream(),
      redirect: (state) {
        String? redirectRoute;
        return state.subloc == redirectRoute ? null : redirectRoute;
      },*/
    );
