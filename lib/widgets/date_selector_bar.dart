import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/bengali_digits.dart';

class DateSelectorBar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final int daysCount;

  const DateSelectorBar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'তারিখ নির্বাচন করুন (পরবর্তী ১০ দিন)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  BengaliFormatter.formatShortDate(selectedDate),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: daysCount,
            itemBuilder: (context, index) {
              final date = today.add(Duration(days: index));
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday = index == 0;
              final isFriday = date.weekday == DateTime.friday;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: isFriday
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('শুক্রবার চেম্বার বন্ধ থাকে। অনুগ্রহ করে অন্য দিন নির্বাচন করুন।'),
                              backgroundColor: AppColors.heartRed,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      : () => onDateSelected(date),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppColors.primaryGradient
                          : null,
                      color: isSelected
                          ? null
                          : (isFriday ? const Color(0xFFF1F5F9) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isToday ? AppColors.primary : AppColors.border),
                        width: isToday && !isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (isToday)
                          Positioned(
                            top: 4,
                            right: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                BengaliFormatter.getBengaliDayName(date.weekday).substring(0, 3),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isFriday
                                      ? AppColors.heartRed
                                      : (isSelected
                                          ? Colors.white70
                                          : AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                BengaliFormatter.toBengaliNumber(date.day),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isFriday
                                      ? AppColors.textMuted
                                      : (isSelected
                                          ? Colors.white
                                          : AppColors.textDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFriday
                                    ? 'বন্ধ'
                                    : (isToday
                                        ? 'আজ'
                                        : BengaliFormatter.getBengaliShortMonthName(date.month)),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isFriday
                                      ? AppColors.heartRed
                                      : (isSelected
                                          ? Colors.white
                                          : (isToday ? AppColors.primary : AppColors.textMuted)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
