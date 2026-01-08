import 'dart:async';

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

  // CRITICAL: Capture the original seed data BEFORE loading persisted items
  // This ensures seedItemsById has the true defaults to reset to
  initializeSeedData();

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

class MyApp extends StatefulWidget {
  final ItemRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Best-effort: flush/close resources when backgrounding.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(widget.repository.close());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.repository.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Count',
      theme: AppTheme.lightTheme,
      home: HomePage(repository: widget.repository),
      debugShowCheckedModeBanner: false,
    );
  }
}
