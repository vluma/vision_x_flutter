import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/features/detail_page/detail_page.dart';
import 'package:vision_x_flutter/features/home/index.dart';
import 'package:vision_x_flutter/features/history/presentation/pages/history_page.dart';
import 'package:vision_x_flutter/features/settings/settings_page.dart';
import 'package:vision_x_flutter/features/main_page.dart';
import 'package:vision_x_flutter/features/search/search_page.dart';
import 'package:vision_x_flutter/features/video_player/video_player_page.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

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
              pageBuilder: (BuildContext context, GoRouterState state) {
                return CupertinoPage(
                child: const HomePage(),
              );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    return CupertinoPage(
                      child: extra is MediaDetail
                          ? DetailPage(id: id, media: extra)
                          : DetailPage(id: id),
                    );
                  },
                ),
                GoRoute(
                  path: 'video',
                  name: 'video_player',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return CupertinoPage(
                    child: VideoPlayerPage(
                      media: extra['media'] as MediaDetail,
                      episode: extra['episode'] as Episode,
                      startPosition: startPosition,
                    ),
                  );
                    }
                    return CupertinoPage(
                    child: const Scaffold(
                      body: Center(
                        child: Text('视频信息不完整'),
                      ),
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
              pageBuilder: (BuildContext context, GoRouterState state) {
                return CupertinoPage(
                child: const HistoryPage(),
              );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    return CupertinoPage(
                    child: extra is MediaDetail
                        ? DetailPage(id: id, media: extra)
                        : DetailPage(id: id),
                  );
                  },
                ),
                GoRoute(
                  path: 'video',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return CupertinoPage(
                        child: VideoPlayerPage(
                          media: extra['media'] as MediaDetail,
                          episode: extra['episode'] as Episode,
                          startPosition: startPosition,
                        ),
                      );
                    }
                    return CupertinoPage(
                      child: const Scaffold(
                        body: Center(
                          child: Text('视频信息不完整'),
                        ),
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
              pageBuilder: (BuildContext context, GoRouterState state) {
                return CupertinoPage(
                child: const SettingsPage(),
              );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    return CupertinoPage(
                      child: extra is MediaDetail
                          ? DetailPage(id: id, media: extra)
                          : DetailPage(id: id),
                    );
                  },
                ),
                GoRoute(
                  path: 'video',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return CupertinoPage(
                        child: VideoPlayerPage(
                          media: extra['media'] as MediaDetail,
                          episode: extra['episode'] as Episode,
                          startPosition: startPosition,
                        ),
                      );
                    }
                    return CupertinoPage(
                      child: const Scaffold(
                        body: Center(
                          child: Text('视频信息不完整'),
                        ),
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
              pageBuilder: (BuildContext context, GoRouterState state) {
                return CupertinoPage(
                child: const SearchPage(),
              );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    return CupertinoPage(
                      child: extra is MediaDetail
                          ? DetailPage(id: id, media: extra)
                          : DetailPage(id: id),
                    );
                  },
                ),
                GoRoute(
                  path: 'video',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is Map &&
                        extra['media'] is MediaDetail &&
                        extra['episode'] is Episode) {
                      final startPosition = extra['startPosition'] as int? ?? 0;
                      return CupertinoPage(
                        child: VideoPlayerPage(
                          media: extra['media'] as MediaDetail,
                          episode: extra['episode'] as Episode,
                          startPosition: startPosition,
                        ),
                      );
                    }
                    return CupertinoPage(
                      child: const Scaffold(
                        body: Center(
                          child: Text('视频信息不完整'),
                        ),
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