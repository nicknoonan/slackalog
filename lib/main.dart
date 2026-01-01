import 'package:slackalog/apiClient.dart';
import 'package:slackalog/layout.dart';
import 'package:slackalog/measurePage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupPage.dart';
import 'package:slackalog/slackSetupRepository.dart';
import 'package:image_picker/image_picker.dart';

final getIt = GetIt.instance;

void main() {
  configureDependencies();
  runApp(
    MaterialApp(
      home: MyApp(),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
    ),
  );
}

void configureDependencies() {
  // Dependency injection setup can be added here
  getIt.registerSingleton<IAPIClient>(
    APIClient(
      baseUrl:
          "https://raw.githubusercontent.com/nicknoonan/slackalog/refs/heads/main",
    ),
  );
  // getIt.registerLazySingleton<ISlackSetupRepository>(
  //   () => ExampleSlackSetupRepository(apiClient: getIt<IAPIClient>()),
  // );
  getIt.registerLazySingleton<ISlackSetupRepository>(
    () => FileStoreSlackSetupRepository(),
  );
  // getIt.registerLazySingleton<ISlackSetupModelList>(() => SlackSetupModelList(list: list))
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // TODO: uses go_router. https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html
    final List<NavItem> navItems = <NavItem>[
      NavItem(label: "home", icon: Icons.home, body: SlackSetupPage()),
      NavItem(label: "map", icon: Icons.map, body: Text("not implemented")),
      NavItem(label: "camera", icon: Icons.camera, body: testImagePicker()),
    ];

    return AppLayout(title: "Slackalog", navItems: navItems);
  }

  Widget testImagePicker() {
    return Scaffold(
      body: SizedBox(),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        // Pick an image.
        final List<XFile>? images = await picker.pickMultiImage();
      }, child: Text("image"),),
    );
  }
}
