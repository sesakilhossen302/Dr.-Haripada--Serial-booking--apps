import 'package:flutter/material.dart';
import '../models/slot_model.dart';
import '../utils/app_colors.dart';
import '../utils/bengali_digits.dart';

class SlotCard extends StatelessWidget {
  final SlotModel slot;
  final bool isSelected;
  final bool isFull;
  final int bookedCount;
  final int totalLimit;
  final VoidCallback onTap;

  const SlotCard({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.isFull,
    required this.bookedCount,
    required this.totalLimit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalLimit - bookedCount;
    final isAvailable = slot.isAvailable && !isFull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isAvailable
                  ? (isSelected ? AppColors.primarySurface.withValues(alpha: 0.5) : Colors.white)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isFull ? AppColors.heartRed.withValues(alpha: 0.3) : AppColors.border),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Time Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isFull
                        ? AppColors.heartRedLight
                        : (isSelected ? AppColors.primary : AppColors.primarySurface),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isFull
                        ? Icons.lock_clock_outlined
                        : Icons.access_time_filled_rounded,
                    color: isFull
                        ? AppColors.heartRed
                        : (isSelected ? Colors.white : AppColors.primary),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Center Information Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Time slot
                      Text(
                        slot.timeRange,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isFull ? AppColors.textMuted : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Chamber name
                      Row(
                        children: [
                          const Icon(Icons.local_hospital_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              slot.chamberName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Capacity / Status Badge
                      _buildStatusBadge(remaining),
                    ],
                  ),
                ),

                // Radio Indicator
                if (isAvailable) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int remaining) {
    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.heartRedLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.heartRed.withValues(alpha: 0.3)),
        ),
        child: const Text(
          'বুকিং সম্পন্ন (স্লট পূর্ণ)',
          style: TextStyle(
            color: AppColors.heartRed,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (!slot.isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'সাময়িক বন্ধ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      final isLow = remaining <= 5;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isLow ? AppColors.warningLight : AppColors.successLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'অবশিষ্ট আসন: ${BengaliFormatter.toBengaliNumber(remaining)}/${BengaliFormatter.toBengaliNumber(totalLimit)}',
          style: TextStyle(
            color: isLow ? AppColors.warningOrange : AppColors.successGreen,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
  }
}
