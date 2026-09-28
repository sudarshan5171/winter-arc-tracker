Build a minimal Flutter app called "Winter Arc" — a daily goal/habit tracker for a personal winter challenge.

TECH STACK:
- Flutter (latest stable), Dart
- Local storage: Hive for all goal/progress data (works fully offline)
- Firebase Firestore + Firebase Anonymous Auth for silent background cloud backup (no login UI ever shown to user; sign in anonymously on first launch)
- State management: Riverpod (or Provider if simpler)
- No third-party UI kits — build custom minimal widgets

DATA MODELS:
- WinterArc: startDate, endDate
- Goal: id, title, icon (emoji string), isPreset (bool), targetValue (nullable int), unit (nullable string), createdAt
- DailyEntry: date, goalId, completed (bool), value (nullable int)

SCREENS:
1. Onboarding (shown only once):
   - Pick Winter Arc start date and end date (date pickers)
   - Select from preset goals (Workout, Water Intake, Sleep 7-8hrs, No Junk Food, Read/Study, Meditation, Steps) via toggleable chips
   - Option to add a custom goal (title + optional emoji + optional target number/unit)
   - "Start My Winter Arc" button

2. Home Screen:
   - Header: "Day X of Winter Arc" + days remaining
   - Overall streak indicator (flame icon + number) at top
   - Scrollable list of today's goals as cards — each with icon, title, and a checkbox/tap-to-complete circle; for numeric goals show a small stepper or input
   - Per-goal small streak badge next to each goal
   - Floating action button to add a new goal anytime

3. Progress Screen:
   - Calendar month view, heatmap-style coloring based on % of goals completed that day (use 4-5 shades of the accent color)
   - Tapping a date shows a bottom sheet with that day's goal completion breakdown
   - Summary stats row: completion %, current streak, longest streak, total active days

4. Add/Edit Goal (bottom sheet modal):
   - Title field, emoji picker (simple grid), optional target value + unit, save/delete buttons

5. Settings Screen:
   - List/reorder/delete existing goals
   - Light/Dark theme toggle
   - Reset streak data (with confirmation dialog)
   - Winter Arc start/end date (editable)

NAVIGATION:
- Bottom navigation bar with exactly 3 tabs: Home, Progress, Settings
- No deep nested navigation — modals/bottom sheets for add/edit flows only

DESIGN SYSTEM:
- Minimal, clean, single accent color: icy blue (#4FA6E0 or similar) on a white background (light mode) and near-black (#121417) background (dark mode)
- One font family (e.g., Inter or Poppins via google_fonts package), 2 weights only (regular, semibold)
- Rounded corners (12-16px radius) on cards, generous padding/whitespace, no heavy shadows — flat design with subtle borders
- Large, easy tap targets (min 48px) for checkboxes
- Simple line icons (use flutter's built-in Icons or a minimal icon pack), avoid decorative illustrations
- Smooth but subtle animations only for checkbox completion and streak updates — no flashy transitions

BEHAVIOR NOTES:
- Goals reset automatically at local midnight
- Anonymous Firebase auth happens silently in background on first launch — sync Hive data to Firestore whenever online, no user-facing auth screens
- App must work fully offline; Firebase sync is best-effort background only

Please scaffold the project structure, models, Hive setup, basic Riverpod providers, and all 5 screens with working navigation. Keep the UI genuinely minimal — no unnecessary decoration.