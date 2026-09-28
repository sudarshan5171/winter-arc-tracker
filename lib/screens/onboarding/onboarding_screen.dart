import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../models/goal_model.dart';
import '../../providers/arc_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  final Set<int> _selectedPresetIndices = {0, 1, 2, 4}; // Default recommended presets
  final List<Goal> _customGoals = [];

  // Controllers for inline custom goal
  final _customTitleController = TextEditingController();
  final _customTargetController = TextEditingController();
  final _customUnitController = TextEditingController();
  String _customEmoji = '🎯';
  bool _customHasTarget = false;
  bool _showCustomGoalInput = false;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 90));
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    _customTargetController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.surfaceDark,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    surface: AppColors.surfaceLight,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _addCustomGoal() {
    final title = _customTitleController.text.trim();
    if (title.isEmpty) return;

    int? targetValue;
    String? unit;
    if (_customHasTarget) {
      targetValue = int.tryParse(_customTargetController.text.trim());
      unit = _customUnitController.text.trim();
      if (unit.isEmpty) unit = null;
    }

    setState(() {
      _customGoals.add(
        Goal(
          id: const Uuid().v4(),
          title: title,
          icon: _customEmoji,
          targetValue: targetValue,
          unit: unit,
          createdAt: DateTime.now(),
        ),
      );
      _customTitleController.clear();
      _customTargetController.clear();
      _customUnitController.clear();
      _customHasTarget = false;
      _showCustomGoalInput = false;
    });
  }

  Future<void> _startWinterArc() async {
    if (_isStarting) return;

    final List<Goal> allGoals = [];

    // Add selected presets
    for (final index in _selectedPresetIndices) {
      final preset = AppDefaults.presetGoals[index];
      allGoals.add(
        Goal(
          id: const Uuid().v4(),
          title: preset['title'] as String,
          icon: preset['icon'] as String,
          isPreset: true,
          targetValue: preset['targetValue'] as int?,
          unit: preset['unit'] as String?,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Add custom goals
    allGoals.addAll(_customGoals);

    if (allGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add at least one goal!')),
      );
      return;
    }

    setState(() => _isStarting = true);

    try {
      // Save arc & goals
      await ref.read(goalsProvider.notifier).addMultipleGoals(allGoals);
      await ref.read(arcProvider.notifier).updateArc(
            startDate: _startDate,
            endDate: _endDate,
            isOnboarded: true,
          );

      // Request notification permissions and schedule daily reminders
      await NotificationService.requestPermissions();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, anim1, anim2) => const MainNavigationScreen(),
            transitionsBuilder: (context, anim, secAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStarting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting Winter Arc: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final totalDays = _endDate.difference(_startDate).inDays + 1;

    final cardBg = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              // Header Icon, Title, and Theme Switcher
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primarySubtleDark : AppColors.primarySubtleLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(100)),
                    ),
                    child: const Text('❄️', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WINTER ARC',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Set Your Challenge',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Theme Mode Toggle Button
                  IconButton.filledTonal(
                    tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    style: IconButton.styleFrom(
                      backgroundColor: cardBg,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(10),
                    ),
                    icon: Icon(
                      themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Focus, discipline, and daily execution. Configure your arc timeline and non-negotiable daily habits.',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),

              // STEP 1: Date Range
              _StepLabel(number: '1', title: 'Timeline & Duration ($totalDays days)'),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dateFormat.format(_startDate)} — ${dateFormat.format(_endDate)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                '$totalDays continuous days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // STEP 2: Preset Habits
              _StepLabel(number: '2', title: 'Select Non-Negotiable Habits'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(AppDefaults.presetGoals.length, (index) {
                  final preset = AppDefaults.presetGoals[index];
                  final isSelected = _selectedPresetIndices.contains(index);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(preset['icon'] as String, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          preset['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.primaryDark)
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPresetIndices.add(index);
                        } else {
                          _selectedPresetIndices.remove(index);
                        }
                      });
                    },
                    backgroundColor: cardBg,
                    selectedColor: isDark ? AppColors.primarySubtleDark : AppColors.primarySubtleLight,
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : borderColor,
                      width: isSelected ? 1.4 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Custom Goals List if any
              if (_customGoals.isNotEmpty) ...[
                Text(
                  'Custom Habits (${_customGoals.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                ..._customGoals.map(
                  (cg) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Text(cg.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cg.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.dangerRed),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          onPressed: () {
                            setState(() => _customGoals.remove(cg));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Inline Custom Goal Adder
              if (_showCustomGoalInput) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(150)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_customEmoji, style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _customTitleController,
                              autofocus: true,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Custom goal name',
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Quick Emoji Selector
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: AppDefaults.availableEmojis.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            final em = AppDefaults.availableEmojis[index];
                            final isSel = em == _customEmoji;
                            return InkWell(
                              onTap: () => setState(() => _customEmoji = em),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary.withAlpha(50) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel ? AppColors.primary : borderColor,
                                    width: isSel ? 1.2 : 0.8,
                                  ),
                                ),
                                child: Text(em, style: const TextStyle(fontSize: 16)),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Numeric Target Toggle
                      InkWell(
                        onTap: () => setState(() => _customHasTarget = !_customHasTarget),
                        child: Row(
                          children: [
                            Icon(
                              _customHasTarget ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                              size: 18,
                              color: _customHasTarget ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Numeric target (optional)',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),

                      if (_customHasTarget) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _customTargetController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 3000',
                                  isDense: true,
                                  labelText: 'Target',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _customUnitController,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'ml, mins',
                                  isDense: true,
                                  labelText: 'Unit',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _showCustomGoalInput = false),
                            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addCustomGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Add Goal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ] else
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showCustomGoalInput = true),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Custom Goal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

              const SizedBox(height: 32),

              // Start My Winter Arc Button
              ElevatedButton(
                onPressed: _startWinterArc,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Start My Winter Arc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String number;
  final String title;

  const _StepLabel({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
