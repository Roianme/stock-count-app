import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(child: ListTile(title: Text('Item 1'))),
                  Wrap(
                    spacing: 12,
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.red[100],
                        onPressed: null,
                        tooltip: 'zero',
                        elevation: 0,
                        child: const Icon(Icons.exposure_zero),
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.amber[100],
                        onPressed: null,
                        tooltip: 'low',
                        elevation: 0,
                        child: const Text('LOW'),
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.green[100],
                        onPressed: null,
                        tooltip: 'OK',
                        elevation: 0,
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
