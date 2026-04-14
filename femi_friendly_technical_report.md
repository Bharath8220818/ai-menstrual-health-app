# Femi-Friendly: Technical Architecture & Project Report

## 📖 1. Overview and Working Model
**Femi-Friendly** is a comprehensive, AI-powered menstrual health and cycle tracking application built entirely with Flutter. Based on the premium "Flowly" Figma UI design system, the app utilizes a highly visual, animated, and user-friendly interface.

### How it Works (Working Model)
The app operates on a centralized architecture driven by the `provider` state management pattern. It heavily relies on synchronous local state holding user configurations and cycle logs, which dynamically alter the layout of the UI (e.g. Current Cycle Phase dictates Daily Recommendations).
- **Authentication & User State (`AuthProvider`)**: Handles secure login, onboarding completion, BMI calculation, and app settings.
- **Cycle Engine (`CycleProvider`)**: Calculates the user's cycle length predictions based on historical logs, identifies the current cycle day, and determines the current physiological phase (Menstrual, Follicular, Ovulation, Luteal) to customize user insights.
- **AI/LLM Stub (`ChatProvider`)**: Serves as the middle layer for communicating with the backend. Currently holds dummy data for predictive insights but is architected to accept standard REST API calls (`/predict`, `/chat`).

---

## 🏗️ 2. Folder Structure
The codebase follows a scalable Feature-first architectural pattern combined with Core/Shared utilities.

```text
lib/
├── core/                       # Shared app-wide base definitions
│   ├── constants/              # app_colors.dart, app_spacing.dart, app_strings.dart
│   ├── navigation/             # Custom route transitions (app_page_route.dart)
│   ├── theme/                  # Material theme configuration (app_theme.dart)
│   └── utils/                  # Reusable helper functions (date formats, feedback UI)
├── models/                     # Data models (chat_message.dart, cycle_entry.dart)
├── providers/                  # Application State variables
│   ├── auth_provider.dart      # User configuration & metrics
│   ├── chat_provider.dart      # AI dialogue context memory
│   └── cycle_provider.dart     # Menstrual math, calendars, logs
├── routes/                     # Centralized named router map & deep links
├── screens/                    # Feature/UI screens (1 module = 1 folder)
│   ├── auth/                   # Login, Register, Onboarding presentations
│   ├── chat/                   # AI Bot interactions & bubbles
│   ├── cycle/                  # TableCalendar setup & menstrual logging bottom sheets
│   ├── dashboard/              # Dynamic Home Dashboard UI
│   ├── home/                   # Shell / Scaffold containing the Bottom Nav Bar
│   ├── insights/               # Daily AI predictive cards
│   ├── notification/           # Notification center & dismissible alerts
│   ├── phase/                  # Dynamic hormone/phase education views
│   ├── profile/                # User profile, settings toggles, logout
│   ├── report/                 # FL Chart integration for health trend visualization
│   ├── setup/                  # 5-Step setup funnel (Name, BMI, Cycle details)
│   ├── splash/                 # Entrance animated loader
│   └── water/                  # Hydration tracker with liquid ring progress
├── widgets/                    # Global generic/reusable UI Components
│   ├── card_widget.dart        # Unified shadow container
│   ├── custom_button.dart      # Primary gradient CTA button
│   ├── cycle_progress_bar.dart # Tracking UI components
│   ├── skeleton_box.dart       # Shimmer loading placeholders
│   └── typing_indicator.dart   # Chatbot typing animations
└── main.dart                   # Entry point and MultiProvider setup
```

---

## 🛠️ 3. Features & Functions Implemented
1. **Premium Thematic UI Framework**
   - Exact implementation of the Figma gradient design system logic (`#E91E63`, `#FFF1F5` backgrounds).
   - Heavy usage of rounded soft-UI components, DropShadow elevation, and animated transitions across all tabs.
2. **Onboarding & User Setup Funnel**
   - Configurable Profile Setup steps handling Health metrics (Age, Slider-based Height/Weight, Circle-dial cycle mapping).
3. **Smart Dashboard Interface**
   - Context-aware display calculating exact Period/Luteal phases.
   - Intelligent suggestion system prescribing Activities, Food, and Mood changes based on the user's specific Cycle Day.
4. **Calendar Tracking System**
   - High-fidelity `table_calendar` integration showing distinct markers for period durations vs ovulation windows.
   - Comprehensive Bottom Sheet logger (Flow level, Symptoms chips).
5. **Interactive Data Views**
   - **Water Tracker:** Interactive GridView map for recording daily glasses of water, integrated with dynamic circle progress.
   - **Health Analytics:** Uses `fl_chart` to construct Bar Charts analyzing the gap trends between cycles and Mood tracking over 28-day sets. 
6. **Chatbot Interface**
   - Simulated conversational interface predicting responses, built with auto-scroll logic, action chip suggestions, and bouncing typing indicators.

---

## 📝 4. Technical Comments & Future Scope
- **Environment Notes:** The app compiles perfectly via `flutter run -d chrome`. If running on Windows Desktop, Developer Mode must be enabled in Windows System Settings due to symlink requirements in the flutter toolchain.
- **Performance:** Extensive use of `/// const` modifiers, optimized state rebuilding using `context.read/watch`, and careful AnimationController disposal prevents memory leaks.
- **Next Steps:** 
  - To utilize the AI feature, integrate an HTTP connection library (like `dio` or standard `http`) replacing the `await Future.delayed` blocks in `chat_provider.dart`.
  - Wire up a persistence layer like `shared_preferences` or `hive` into the init constructors of the Providers so cycle data survives app restarts.
