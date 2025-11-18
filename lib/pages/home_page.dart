import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_local_db/models/task.dart';
import 'package:learn_local_db/services/database_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _newTask;
  List<Task> tasks = [];

  @override
  void initState() {
    _loadTask();
    super.initState();
  }

  Future<void> _loadTask() async {
    tasks = await _databaseService.getTasks();
    setState(() {});
  }

  Future<void> _addTask() async {
    if (_newTask == null || _newTask!.trim().isEmpty) return;

    await _databaseService.addTask(_newTask!.trim());
    await _loadTask();

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Task Added")));

    setState(() => _newTask = null);
  }

  Future<void> _editTask(Task task) async {
    if (_newTask == null || _newTask!.trim().isEmpty) return;

    await _databaseService.editTaskContent(task.id, _newTask!.trim());
    await _loadTask();

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Task has been updated")));

    setState(() => _newTask = null);
  }

  Future<void> _updateTaskStatus(Task task) async {
    final newStatus = task.status == 0 ? 1 : 0;

    await _databaseService.updateTaskStatus(task.id, newStatus);
    await _loadTask();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 1 ? "Task Completed" : "Marked as Incomplete",
        ),
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    await _databaseService.deleteTask(task.id);
    await _loadTask();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Task has been deleted")));
  }

  Future<void> _deleteAll() async {
    if (tasks.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nothing to delete")));
      return;
    }

    await _databaseService.deleteAllTasks();
    await _loadTask();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All tasks have been deleted")),
    );
  }

  void _openAddDialog(String title, Function() callBack) {
    showDialog(context: context, builder: (_) => _taskBox(title, callBack));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: AppBar(
          title: Text(
            "ToDo",
            style: GoogleFonts.satisfy(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
          actions: [
            TextButton(onPressed: _deleteAll, child: const Text("Empty Task")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog("Add", () => _addTask()),
        child: const Icon(Icons.add, size: 30, color: Colors.black54),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("No Task Added yet"))
          : Padding(
              padding: const EdgeInsets.only(top: 35),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, index) {
                  final task = tasks[index];
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () => _updateTaskStatus(task),
                          leading: Icon(
                            task.status == 1
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: task.status == 1
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(
                            task.content,
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: task.status == 1
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.deepOrange,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openAddDialog(
                                  "Update",
                                  () => _editTask(task),
                                ),
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => _deleteTask(task),
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _taskBox(String title, Function() callBack) {
    return AlertDialog(
      title: Text("$title Task"),
      content: TextField(
        onChanged: (value) => setState(() => _newTask = value),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Task name...",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: callBack,
          color: Theme.of(context).colorScheme.primary,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
