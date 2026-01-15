import 'package:flutter/material.dart';
import 'screens/todo_preview_screen.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final List<TextEditingController> _todoControllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    // Start with one empty todo
    _addNewTodo();
  }

  @override
  void dispose() {
    for (var controller in _todoControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addNewTodo() {
    setState(() {
      _todoControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todoControllers[index].dispose();
      _focusNodes[index].dispose();
      _todoControllers.removeAt(index);
      _focusNodes.removeAt(index);
    });
  }

  void _openPreview() {
    final todos = _todoControllers
        .map((controller) => controller.text)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoPreviewScreen(todos: todos)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            tooltip: 'Preview & Export',
            onPressed: _openPreview,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _todoControllers.isEmpty
                ? Center(
                    child: Text(
                      'No todos yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _todoControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _todoControllers[index],
                                focusNode: _focusNodes[index],
                                decoration: InputDecoration(
                                  hintText: 'Enter todo...',
                                  prefixIcon: const Icon(Icons.circle_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red[400],
                              onPressed: () => _removeTodo(index),
                              tooltip: 'Remove todo',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addNewTodo,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Todo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openPreview,
                      icon: const Icon(Icons.preview),
                      label: const Text('Preview & Export'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue.shade700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
