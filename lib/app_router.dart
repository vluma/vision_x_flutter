import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/pages/home_page.dart';
import 'package:vision_x_flutter/pages/history_page.dart';
import 'package:vision_x_flutter/pages/settings_page.dart';
import 'package:vision_x_flutter/pages/main_page.dart';
import 'package:vision_x_flutter/pages/detail_page.dart';
import 'package:vision_x_flutter/pages/search_page.dart';

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

        if (isMainTab) {
          return MainPage(
            currentPath: currentPath,
            child: navigationShell,
          );
        }

        // 对于非主标签页，直接返回导航壳
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
                    final id = state.pathParameters['id'];
                    return DetailPage(id: id);
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
                    final id = state.pathParameters['id'];
                    return DetailPage(id: id);
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
                    final id = state.pathParameters['id'];
                    return DetailPage(id: id);
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
                    final id = state.pathParameters['id'];
                    return DetailPage(id: id);
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
