import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import 'day_breakdown_sheet.dart';

class HeatmapCalendar extends StatefulWidget {
  final Map<String, double> heatmapRatios;
  final DateTime arcStartDate;
  final DateTime arcEndDate;

  const HeatmapCalendar({
    super.key,
    required this.heatmapRatios,
    required this.arcStartDate,
    required this.arcEndDate,
  });

  @override
  State<HeatmapCalendar> createState() => _HeatmapCalendarState();
}

class _HeatmapCalendarState extends State<HeatmapCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  Color _getHeatmapColor(double ratio, bool isDark, bool isToday, bool isInArc) {
    if (!isInArc) {
      return Colors.transparent;
    }
    final palette = isDark ? AppColors.heatmapDark : AppColors.heatmapLight;
    if (ratio <= 0.0) return palette[0];
    if (ratio <= 0.25) return palette[1];
    if (ratio <= 0.50) return palette[2];
    if (ratio <= 0.75) return palette[3];
    return palette[4];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final monthFormat = DateFormat('MMMM yyyy');
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    // Monday = 1, Sunday = 7
    final firstWeekday = firstDayOfMonth.weekday; // 1 to 7

    // Start & End of Arc (date only)
    final arcStart = DateTime(widget.arcStartDate.year, widget.arcStartDate.month, widget.arcStartDate.day);
    final arcEnd = DateTime(widget.arcEndDate.year, widget.arcEndDate.month, widget.arcEndDate.day);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Month Header & Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthFormat.format(_displayedMonth),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: _prevMonth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day of week headers (Mon - Sun)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _DayHeader('M'),
              _DayHeader('T'),
              _DayHeader('W'),
              _DayHeader('T'),
              _DayHeader('F'),
              _DayHeader('S'),
              _DayHeader('S'),
            ],
          ),
          const SizedBox(height: 8),

          // Grid of calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (firstWeekday - 1) + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - (firstWeekday - 1) + 1;
              final cellDate = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
              final cellDateStr = dateFormat.format(cellDate);
              final isCellToday = cellDate.isAtSameMomentAs(today);
              final isFuture = cellDate.isAfter(today);

              final isInArc = !cellDate.isBefore(arcStart) && !cellDate.isAfter(arcEnd);
              final ratio = widget.heatmapRatios[cellDateStr] ?? 0.0;
              final cellBgColor = _getHeatmapColor(ratio, isDark, isCellToday, isInArc);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => DayBreakdownSheet.show(context, cellDate),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cellBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCellToday
                            ? AppColors.primary
                            : (isInArc && ratio > 0.5
                                ? Colors.transparent
                                : (isDark
                                    ? AppColors.borderDark.withAlpha(100)
                                    : AppColors.borderLight)),
                        width: isCellToday ? 1.5 : 0.8,
                      ),
                    ),
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCellToday ? FontWeight.w600 : FontWeight.w500,
                        color: !isInArc || isFuture
                            ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                            : (ratio >= 0.50
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Heatmap Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completion Scale',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              Row(
                children: [
                  Text(
                    '0%',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...List.generate(5, (i) {
                    final palette = isDark ? AppColors.heatmapDark : AppColors.heatmapLight;
                    return Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: palette[i],
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          width: 0.5,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 6),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 28,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }
}
