import 'package:flutter/material.dart';
import '../dashboard/components/main_scaffold.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Task> tasks = [
    Task('Sabah Namazı', true),
    Task('Kuran Okuma', false),
    Task('Zikir Yapma', false),
    Task('Sadaka Verme', true),
  ];
  int _currentIndex = 3; // Görevler sayfası indexi

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _currentIndex,
      title: 'Günlük Görevlerim',
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(tasks[index].title),
                  value: tasks[index].isCompleted,
                  onChanged: (bool? value) {
                    setState(() => tasks[index].isCompleted = value!);
                  },
                  secondary: Icon(
                    tasks[index].isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: tasks[index].isCompleted ? Colors.green : Colors.grey,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tamamlanan: ${tasks.where((t) => t.isCompleted).length}/${tasks.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _addNewTask,
                  child: const Text('Yeni Görev Ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        String newTaskTitle = '';
        return AlertDialog(
          title: const Text('Yeni Görev Ekle'),
          content: TextField(
            onChanged: (value) => newTaskTitle = value,
            decoration: const InputDecoration(hintText: 'Görev adı'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newTaskTitle.isNotEmpty) {
                  setState(() => tasks.add(Task(newTaskTitle, false)));
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task(this.title, this.isCompleted);
}