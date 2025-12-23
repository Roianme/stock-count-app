import 'package:flutter/material.dart';
import 'view/home_view.dart';
import 'data/hive_item_repository.dart';
import 'data/item_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize repository and load items
  final repository = HiveItemRepository();
  await repository.initialize();

  // Load persisted items into memory
  final loadedItems = await repository.loadItems();
  items
    ..clear()
    ..addAll(loadedItems);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final HiveItemRepository repository;

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
