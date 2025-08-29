import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/pages/home/home_page.dart';
import 'package:vision_x_flutter/pages/history/history_page.dart';
import 'package:vision_x_flutter/pages/settings/settings_page.dart';
import 'package:vision_x_flutter/pages/main_page.dart';
import 'package:vision_x_flutter/pages/detail_page.dart';
import 'package:vision_x_flutter/pages/search/search_page.dart';
import 'package:vision_x_flutter/pages/video_player/video_player_page.dart';
import 'package:vision_x_flutter/models/media_detail.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        final currentPath = state.uri.toString();
        final isMainTab = currentPath == '/' ||
            currentPath.startsWith('/history') ||
            currentPath.startsWith('/settings') ||
            currentPath.startsWith('/search');
        final isSubPage =
            currentPath.contains('/detail/') || currentPath.contains('/video');

        if (isMainTab && !isSubPage) {
          return MainPage(
            currentPath: currentPath,
            child: navigationShell,
          );
        }
        return navigationShell;
      },
      branches: <StatefulShellBranch>[
        // Home branch
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const HomePage();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    if (extra is MediaDetail) {
                      return DetailPage(id: id, media: extra);
                    }
                    return DetailPage(id: id);
                  },
                ),
                GoRoute(
                  path: 'video',
                  name: 'video_player',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return VideoPlayerPage(
                        media: extra['media'] as MediaDetail,
                        episode: extra['episode'] as Episode,
                        startPosition: startPosition,
                      );
                    }
                    return const Scaffold(
                      body: Center(
                        child: Text('视频信息不完整'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // History branch
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/history',
              builder: (BuildContext context, GoRouterState state) {
                return const HistoryPage();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    if (extra is MediaDetail) {
                      return DetailPage(id: id, media: extra);
                    }
                    return DetailPage(id: id);
                  },
                ),
                GoRoute(
                  path: 'video',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return VideoPlayerPage(
                        media: extra['media'] as MediaDetail,
                        episode: extra['episode'] as Episode,
                        startPosition: startPosition,
                      );
                    }
                    return const Scaffold(
                      body: Center(
                        child: Text('视频信息不完整'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Settings branch
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsPage();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    if (extra is MediaDetail) {
                      return DetailPage(id: id, media: extra);
                    }
                    return DetailPage(id: id);
                  },
                ),
                GoRoute(
                  path: 'video',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return VideoPlayerPage(
                        media: extra['media'] as MediaDetail,
                        episode: extra['episode'] as Episode,
                        startPosition: startPosition,
                      );
                    }
                    return const Scaffold(
                      body: Center(
                        child: Text('视频信息不完整'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Search branch
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/search',
              builder: (BuildContext context, GoRouterState state) {
                return const SearchPage();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    if (extra is MediaDetail) {
                      return DetailPage(id: id, media: extra);
                    }
                    return DetailPage(id: id);
                  },
                ),
                GoRoute(
                  path: 'video',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return VideoPlayerPage(
                        media: extra['media'] as MediaDetail,
                        episode: extra['episode'] as Episode,
                        startPosition: startPosition,
                      );
                    }
                    return const Scaffold(
                      body: Center(
                        child: Text('视频信息不完整'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
