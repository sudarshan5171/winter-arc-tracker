import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../models/goal_model.dart';
import '../../providers/goals_provider.dart';

class AddEditGoalSheet extends ConsumerStatefulWidget {
  final Goal? initialGoal;

  const AddEditGoalSheet({super.key, this.initialGoal});

  static Future<void> show(BuildContext context, {Goal? goal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditGoalSheet(initialGoal: goal),
    );
  }

  @override
  ConsumerState<AddEditGoalSheet> createState() => _AddEditGoalSheetState();
}

class _AddEditGoalSheetState extends ConsumerState<AddEditGoalSheet> {
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _unitController;
  late String _selectedEmoji;
  late bool _hasTarget;

  @override
  void initState() {
    super.initState();
    final g = widget.initialGoal;
    _titleController = TextEditingController(text: g?.title ?? '');
    _targetController =
        TextEditingController(text: g?.targetValue?.toString() ?? '');
    _unitController = TextEditingController(text: g?.unit ?? '');
    _selectedEmoji = g?.icon ?? '🎯';
    _hasTarget = g?.isNumeric ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    int? targetValue;
    String? unit;
    if (_hasTarget) {
      targetValue = int.tryParse(_targetController.text.trim());
      unit = _unitController.text.trim();
      if (unit.isEmpty) unit = null;
    }

    if (widget.initialGoal != null) {
      final updated = widget.initialGoal!.copyWith(
        title: title,
        icon: _selectedEmoji,
        targetValue: targetValue,
        unit: unit,
      );
      ref.read(goalsProvider.notifier).updateGoal(updated);
    } else {
      final newGoal = Goal(
        id: const Uuid().v4(),
        title: title,
        icon: _selectedEmoji,
        targetValue: targetValue,
        unit: unit,
        createdAt: DateTime.now(),
      );
      ref.read(goalsProvider.notifier).addGoal(newGoal);
    }

    Navigator.of(context).pop();
  }

  void _deleteGoal() {
    if (widget.initialGoal != null) {
      ref.read(goalsProvider.notifier).deleteGoal(widget.initialGoal!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final isEditing = widget.initialGoal != null;

    final bgColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Goal' : 'New Goal',
                  style: theme.textTheme.titleLarge,
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.dangerRed, size: 22),
                    onPressed: _deleteGoal,
                    tooltip: 'Delete Goal',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g., Read 30 pages, Workout, Sleep 8 hrs',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                labelText: 'Goal Title',
                filled: true,
                fillColor: isDark
                    ? AppColors.cardDark
                    : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Emoji Selection
            Text(
              'Select Icon',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppDefaults.availableEmojis.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final emoji = AppDefaults.availableEmojis[index];
                  final isSelected = emoji == _selectedEmoji;
                  return InkWell(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.primarySubtleDark
                                : AppColors.primarySubtleLight)
                            : (isDark
                                ? AppColors.cardDark
                                : AppColors.backgroundLight),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Numeric Target Toggle
            InkWell(
              onTap: () => setState(() => _hasTarget = !_hasTarget),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasTarget
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      color: _hasTarget
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Numeric Target (Optional)',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Track daily numbers like 3000 ml, 45 mins, 8 hrs',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_hasTarget) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'e.g. 3000',
                        labelText: 'Target Number',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.cardDark
                            : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _unitController,
                      textCapitalization: TextCapitalization.none,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'ml, mins, hrs',
                        labelText: 'Unit',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.cardDark
                            : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Add Goal',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
