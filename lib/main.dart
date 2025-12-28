import 'package:slackalog/apiClient.dart';
import 'package:slackalog/layout.dart';
import 'package:slackalog/measurePage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:slackalog/slackSetupRepository.dart';

final getIt = GetIt.instance;

void main() {
  configureDependencies();
  runApp(
    MaterialApp(
      home: MyApp(),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    ),
  );
}

void configureDependencies() {
  // Dependency injection setup can be added here
  getIt.registerSingleton<IAPIClient>(APIClient(baseUrl: "https://localhost"));
  getIt.registerLazySingleton<ISlackSetupRepository>(
    () => SlackSetupRepository(apiClient: getIt<IAPIClient>()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = <NavItem>[
      NavItem(label: "ARTest", icon: Icons.camera, body: MeasurePage()),
      NavItem(label: "home", icon: Icons.home, body: Text("not implemented")),
      NavItem(label: "map", icon: Icons.map, body: Text("not implemented")),
    ];

    return AppLayout(title: "Slackalog", navItems: navItems);
  }
}
