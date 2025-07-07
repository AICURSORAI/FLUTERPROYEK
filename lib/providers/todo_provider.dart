import 'package:flutter/foundation.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoading = false;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate loading - in real app, load from database
    await Future.delayed(const Duration(milliseconds: 500));
    
    _todos = [
      Todo(
        id: 1,
        title: 'Welcome to Todo Notes App!',
        description: 'This is your first todo item',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    notifyListeners();
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo.copyWith(
        isCompleted: !todo.isCompleted,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int id) async {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }
}
