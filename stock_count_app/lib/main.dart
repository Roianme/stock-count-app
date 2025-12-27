import 'package:flutter/material.dart';
import 'view/home_view.dart';
import 'data/platform_item_repository.dart';
import 'data/item_data.dart';
import 'data/item_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: HomePage(repository: repository),
      debugShowCheckedModeBanner: false,
    );
  }
}
