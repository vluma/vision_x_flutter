import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/pages/home_page.dart';
import 'package:vision_x_flutter/pages/history_page.dart';
import 'package:vision_x_flutter/pages/settings_page.dart';
import 'package:vision_x_flutter/pages/main_page.dart';
import 'package:vision_x_flutter/pages/detail_page.dart';
import 'package:vision_x_flutter/pages/search_page.dart';
import 'package:vision_x_flutter/pages/video_player_page.dart';
import 'package:vision_x_flutter/models/media_detail.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        // 这里我们根据当前路径决定是否显示底部导航栏
        final currentPath = state.uri.toString();
        final isMainTab = currentPath == '/' ||
            currentPath.startsWith('/history') ||
            currentPath.startsWith('/settings') ||
            currentPath.startsWith('/search');

        // 检查是否为二级页面（详情页或视频播放页）
        final isSubPage = currentPath.contains('/detail/') || 
            currentPath.contains('/video');

        // 只有主页面才显示底部导航栏，二级页面不显示
        if (isMainTab && !isSubPage) {
          return MainPage(
            currentPath: currentPath,
            child: navigationShell,
          );
        }

        // 对于非主标签页或二级页面，直接返回导航壳
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
                // Home页面的子路由
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

        // History branch
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/history',
              builder: (BuildContext context, GoRouterState state) {
                return const HistoryPage();
              },
              routes: <RouteBase>[
                // History页面的子路由
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
                // Settings页面的子路由
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
                // Search页面的子路由
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