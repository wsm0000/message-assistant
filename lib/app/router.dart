import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/message_detail/message_detail_page.dart';
import '../presentation/pages/keyword_config/keyword_list_page.dart';
import '../presentation/pages/keyword_config/keyword_edit_page.dart';
import '../presentation/pages/history/history_page.dart';
import '../presentation/pages/route_calc/route_calc_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/stats/stats_page.dart';

/// Tab index constants for the bottom-nav destinations.
class MainTab {
  static const messages = 0;
  static const keywords = 1;
  static const history = 2;
  static const settings = 3;
}

const _destinations = <NavigationDestination>[
  NavigationDestination(
    icon: Icon(Icons.chat_bubble_outline),
    selectedIcon: Icon(Icons.chat_bubble),
    label: '消息',
  ),
  NavigationDestination(
    icon: Icon(Icons.tag_outlined),
    selectedIcon: Icon(Icons.tag),
    label: '关键词',
  ),
  NavigationDestination(
    icon: Icon(Icons.history_outlined),
    selectedIcon: Icon(Icons.history),
    label: '历史',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: '设置',
  ),
];

/// App-wide [GoRouter] config. Uses a [StatefulShellRoute.indexedStack] to host
/// a Material 3 [NavigationBar] with 4 tabs (消息 / 关键词 / 历史 / 设置); each
/// tab owns its own navigation stack via a [StatefulShellBranch].
///
/// Branch routes:
///   消息 (0):   HomePage, /message/:id, /stats
///   关键词 (1): KeywordListPage (/keywords), /keywords/new, /keywords/edit/:id
///   历史 (2):   HistoryPage
///   设置 (3):   SettingsPage
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // The shell hosts the bottom-nav Scaffold; the active branch's
        // navigation stack is the body via [NavigationShell].
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // 消息 branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (c, s) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'message/:id',
                  builder: (c, s) =>
                      MessageDetailPage(id: s.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'stats',
                  builder: (c, s) => const StatsPage(),
                ),
                GoRoute(
                  path: 'route_calc',
                  builder: (c, s) => const RouteCalcPage(),
                ),
              ],
            ),
          ],
        ),
        // 关键词 branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/keywords',
              builder: (c, s) => const KeywordListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (c, s) => const KeywordEditPage(),
                ),
                GoRoute(
                  path: 'edit/:id',
                  builder: (c, s) =>
                      KeywordEditPage(editingId: s.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        // 历史 branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (c, s) => const HistoryPage(),
            ),
          ],
        ),
        // 设置 branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (c, s) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Hosts the bottom navigation bar and renders the active branch's navigation
/// stack as the body. Tapping a destination switches branches via
/// [StatefulNavigationShell.goBranch].
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: _destinations,
      ),
    );
  }
}
