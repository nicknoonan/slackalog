import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:slackalog/apiClient.dart';
import 'package:slackalog/layout.dart';
import 'package:slackalog/slackSetupPage.dart';
import 'package:slackalog/slackSetupRepository.dart';
import 'package:slackalog/slackSetupDetailsPage.dart';
import 'package:slackalog/slackSetupUpsertPage.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/map_page.dart';

final getIt = GetIt.instance;

void main() {
  configureDependencies();
  runApp(const MyApp());
}

void configureDependencies() {
  // Dependency injection setup can be added here
  getIt.registerSingleton<IAPIClient>(
    APIClient(
      baseUrl:
          "https://raw.githubusercontent.com/nicknoonan/slackalog/refs/heads/main",
    ),
  );
  getIt.registerLazySingleton<ISlackSetupRepository>(
    () => FileStoreSlackSetupRepository(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'home',
                  builder: (context, state) => const SlackSetupPage(),
                  routes: [
                    GoRoute(
                      path: 'details/:id',
                      name: 'details',
                      builder: (context, state) {
                        final uri = Uri.parse(state.location);
                        final id = uri.pathSegments.isNotEmpty
                            ? uri.pathSegments.last
                            : '';
                        return DetailsRouteWrapper(id: id);
                      },
                    ),
                    GoRoute(
                      path: 'upsert',
                      name: 'upsert_create',
                      builder: (context, state) => const UpsertRouteWrapper(),
                    ),
                    GoRoute(
                      path: 'upsert/:id',
                      name: 'upsert',
                      builder: (context, state) {
                        final uri = Uri.parse(state.location);
                        final id = uri.pathSegments.isNotEmpty
                            ? uri.pathSegments.last
                            : null;
                        return UpsertRouteWrapper(id: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/map',
                  name: 'map',
                  builder: (context, state) {
                    final qp = Uri.parse(state.location).queryParameters;
                    LatLng? center;
                    double? zoom;
                    if (qp.containsKey('lat') && qp.containsKey('lon')) {
                      try {
                        center = LatLng(
                          double.parse(qp['lat']!),
                          double.parse(qp['lon']!),
                        );
                      } catch (_) {}
                    }
                    if (qp.containsKey('zoom')) {
                      try {
                        zoom = double.parse(qp['zoom']!);
                      } catch (_) {}
                    }
                    return MapPage(initialCenter: center, initialZoom: zoom);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      // Optionally add an error page
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Page not found')),
      ),
    );

    return MaterialApp.router(
      title: 'Slackalog',
      routerConfig: _router,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
    );
  }
}

class DetailsRouteWrapper extends StatelessWidget {
  final String id;

  const DetailsRouteWrapper({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SlackSetupModelList>(
      future: getIt<ISlackSetupRepository>().getSlackSetups(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final model = snap.data!.list.firstWhere(
          (m) => m.id.uuid == id,
          orElse: () => throw Exception('Not found'),
        );
        return SlackSetupDetailsPage(
          slackSetup: model,
          onDelete: (s) async {
            await getIt<ISlackSetupRepository>().deleteSlackSetup(s);
            // After delete, go back to home
            context.go('/');
          },
        );
      },
    );
  }
}

class UpsertRouteWrapper extends StatelessWidget {
  final String? id;

  const UpsertRouteWrapper({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const SlackSetupUpsertPage(title: 'Create');
    }

    return FutureBuilder<SlackSetupModelList>(
      future: getIt<ISlackSetupRepository>().getSlackSetups(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final model = snap.data!.list.firstWhere(
          (m) => m.id.uuid == id,
          orElse: () => throw Exception('Not found'),
        );
        return SlackSetupUpsertPage(slackSetup: model, title: 'Update');
      },
    );
  }
}
