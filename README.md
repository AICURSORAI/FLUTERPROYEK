# Todo Notes App

![Flutter CI/CD](https://github.com/yourusername/todo_notes_app/workflows/Flutter%20CI/CD/badge.svg)
![Flutter Version](https://img.shields.io/badge/Flutter-3.16.0-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.2.0-blue.svg)

A comprehensive Todo and Notes application built with Flutter, featuring local storage, notifications, and backup functionality.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/todo_notes_app.git
cd todo_notes_app

# Install dependencies
flutter pub get

# Generate code files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

## ✨ Features

### 📝 Todo Management
- ✅ Create, edit, and delete todos
- 🎯 Set priorities (Low, Medium, High)
- 📅 Due date and time reminders
- 📂 Categorize todos
- ✔️ Mark todos as complete/incomplete
- 🔍 Search and filter todos
- ⏰ Overdue todo detection

### 📓 Notes Management
- 📝 Create, edit, and delete notes
- ❤️ Mark notes as favorites
- 🏷️ Add tags to notes
- 📂 Categorize notes
- 🔍 Search through notes content

### 🔔 Notifications
- ⏰ Reminder notifications for todos
- 🔕 Notification management
- 📱 Background notification support

### 🎨 User Interface
- 🌙 Dark and light theme support
- 📱 Responsive design
- 🎯 Material Design 3
- 📊 Statistics and insights

### 💾 Data Management
- 🗄️ Local SQLite database
- 📤 Export data to JSON
- 📥 Import data from backup
- 🔄 Backup history management

## 🏗️ Architecture

```
lib/
├── models/           # Data models (Todo, Note)
├── providers/        # State management (Provider)
├── services/         # Business logic services
├── screens/          # UI screens
├── widgets/          # Reusable UI components
└── main.dart         # App entry point
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.16.0
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Notifications**: flutter_local_notifications
- **Architecture**: Clean Architecture with Repository Pattern

## 📱 Screenshots

| Home Screen | Todo List | Notes List | Settings |
|-------------|-----------|------------|----------|
| ![Home](screenshots/home.png) | ![Todos](screenshots/todos.png) | ![Notes](screenshots/notes.png) | ![Settings](screenshots/settings.png) |

## 🚀 CI/CD

This project includes a comprehensive GitHub Actions workflow:

- ✅ Automated testing
- ✅ Code quality checks
- ✅ APK/AAB build generation
- ✅ Automated releases

## 📦 Dependencies

### Core
- `provider: ^6.1.1` - State management
- `sqflite: ^2.3.0` - Local database
- `flutter_local_notifications: ^16.3.2` - Notifications
- `intl: ^0.19.0` - Date formatting

### Development
- `flutter_test` - Testing framework
- `flutter_lints: ^3.0.1` - Linting
- `json_serializable: ^6.7.1` - JSON serialization
- `build_runner: ^2.4.7` - Code generation

## 🧪 Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 📱 Building

### Debug
```bash
flutter run
```

### Release APK
```bash
flutter build apk --release
```

### Release App Bundle (Play Store)
```bash
flutter build appbundle --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues:
1. Check the [Issues](https://github.com/yourusername/todo_notes_app/issues) page
2. Create a new issue with detailed information
3. Contact: support@todonotesapp.com

---

**Made with ❤️ using Flutter**
