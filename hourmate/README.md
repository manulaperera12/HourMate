# HourMate - Work Hours Logger with Task Tracking

HourMate is a modern Flutter application designed to help you track your work hours, tasks, and productivity. Built with clean architecture principles and BLoC pattern for state management.

## 🚀 Features

### Core Features
- **⏱️ Clock In/Out**: One-tap action to start and end work sessions
- **🗓️ Daily Log**: View a list of previous work entries with time, task, and rating
- **🧠 Task Description**: Add detailed descriptions of what you're working on
- **⭐ Task Rating**: Rate tasks as Good, Average, or Bad using intuitive emoji UI
- **💬 Optional Comments**: Add notes about roadblocks, mood, client issues, etc.
- **📊 Weekly Summary**: View total hours worked and task quality summary
- **📄 PDF Export**: Generate shareable weekly timesheets (coming soon)
- **⚙️ Settings**: Theme toggle, user preferences, and notifications (coming soon)

### UI/UX Highlights
- **Modern Design**: Inspired by the Daily Step Tracker app with clean, intuitive interface
- **Real-time Updates**: Live timer for active work sessions
- **Responsive Layout**: Works seamlessly across different screen sizes
- **Dark/Light Theme**: Automatic theme switching based on system preferences

## 🏗️ Architecture

HourMate follows **Clean Architecture** principles with **BLoC pattern** for state management (no Provider dependency):

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── theme/             # UI theme and styling
│   └── utils/             # Utility functions
├── features/
│   ├── work_tracking/     # Main work tracking feature
│   │   ├── data/          # Data layer
│   │   │   ├── datasources/   # Local data sources
│   │   │   ├── models/        # Data models
│   │   │   └── repositories/  # Repository implementations
│   │   ├── domain/        # Business logic layer
│   │   │   ├── entities/      # Business entities
│   │   │   ├── repositories/  # Repository interfaces
│   │   │   └── usecases/      # Business use cases
│   │   └── presentation/  # UI layer
│   │       ├── blocs/         # BLoC state management
│   │       ├── pages/         # Screen pages
│   │       └── widgets/       # Reusable UI components
│   └── settings/          # Settings feature (coming soon)
└── main.dart              # App entry point
```

## 🛠️ Technology Stack

- **Framework**: Flutter 3.8+
- **State Management**: flutter_bloc (BLoC pattern)
- **Local Storage**: SharedPreferences
- **PDF Generation**: pdf package
- **Charts**: fl_chart
- **Date/Time**: intl
- **UI Components**: google_fonts, flutter_svg
- **Utilities**: uuid, equatable

## 📱 Screenshots

### Home Screen
- Large, prominent clock in/out button
- Real-time work session timer
- Today's work summary
- Quick access to work log and summary

### Clock In Modal
- Task description input
- Task rating selection (Good/Average/Bad)
- Optional comments field
- Modern form design

### Work Status Card
- Live duration timer
- Task information display
- Visual status indicators

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/hourmate.git
   cd hourmate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📊 Data Structure

### WorkEntry Entity
```dart
class WorkEntry {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final String taskDescription;
  final String taskRating; // 'Good', 'Average', 'Bad'
  final String? taskComment;
}
```

### Storage
- **Local Storage**: SharedPreferences for persistent data
- **Data Format**: JSON serialization for work entries
- **Backup**: Local device storage only (cloud sync coming soon)

## 🎨 Design System

### Color Palette
- **Primary**: Light Green (#90E783)
- **Secondary**: Bright Cyan (#3CD0FE)
- **Accent**: Dark Blue (#0014F0)
- **Surface**: Light Grey/White (#F8F8F6)
- **Error**: Orange-Red (#E3501C)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Weights**: Regular, Medium, SemiBold, Bold
- **Responsive**: Scales appropriately across devices

## 🔧 Configuration

### App Constants
Key configuration values can be found in `lib/core/constants/app_constants.dart`:
- Task rating options
- Storage keys
- Time formats
- UI constants
- Validation limits

### Theme Customization
The app theme is defined in `lib/core/theme/app_theme.dart` and can be easily customized for:
- Colors
- Typography
- Component styles
- Dark/light mode

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📈 Roadmap

### Phase 1 (Current)
- ✅ Basic work tracking functionality
- ✅ Clock in/out with task details
- ✅ Work log viewing
- ✅ Weekly summary
- ✅ Modern UI/UX

### Phase 2 (Coming Soon)
- 📄 PDF export functionality
- ⚙️ Settings page
- 🌙 Enhanced theme customization
- 📊 Advanced analytics and charts
- 🔔 Notifications and reminders

### Phase 3 (Future)
- ☁️ Cloud synchronization
- 👥 Team collaboration features
- 📱 Widget support
- 🔗 API integration
- 📈 Advanced reporting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Design Inspiration**: Daily Step Tracker app from Behance
- **Architecture**: Clean Architecture principles by Robert C. Martin
- **State Management**: BLoC pattern by Felix Angelov
- **UI Components**: Flutter Material Design

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Check the documentation
- Contact the development team

---

**Made with ❤️ using Flutter**
