import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'view/home_view.dart';
import 'data/platform_item_repository.dart';
import 'data/item_data.dart';
import 'data/item_repository.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize platform-aware repository (uses Hive on mobile, SharedPreferences on web)
  final repository = PlatformItemRepository();
  await repository.initialize();

  // Load persisted items into memory
  final loadedItems = await repository.loadItems();
  items
    ..clear()
    ..addAll(loadedItems);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ItemRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Count',
      theme: AppTheme.lightTheme,
      home: HomePage(repository: repository),
      debugShowCheckedModeBanner: false,
    );
  }
}
