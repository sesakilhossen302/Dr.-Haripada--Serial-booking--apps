import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../utils/app_colors.dart';
import '../utils/bengali_digits.dart';

class SerialTokenDialog extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onViewHistory;

  const SerialTokenDialog({
    super.key,
    required this.appointment,
    required this.onViewHistory,
  });

  static Future<void> show(
    BuildContext context, {
    required AppointmentModel appointment,
    required VoidCallback onViewHistory,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SerialTokenDialog(
        appointment: appointment,
        onViewHistory: onViewHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookedTime = appointment.bookedAt;
    final hour = bookedTime.hour > 12 ? bookedTime.hour - 12 : (bookedTime.hour == 0 ? 12 : bookedTime.hour);
    final amPm = bookedTime.hour >= 12 ? 'PM' : 'AM';
    final minute = bookedTime.minute.toString().padLeft(2, '0');
    final second = bookedTime.second.toString().padLeft(2, '0');
    final ms = (bookedTime.millisecond).toString().padLeft(3, '0');
    final exactTimeBengali = "${BengaliFormatter.toBengaliNumber(hour)}:${BengaliFormatter.toBengaliNumber(minute)}:${BengaliFormatter.toBengaliNumber(second)}.$ms $amPm";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with success badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'বুকিং সফল হয়েছে!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'টোকেন নং: ${appointment.tokenCode}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Main Pass Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Giant Serial Number Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'আপনার নির্ধারিত সিরিয়াল নং',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              BengaliFormatter.formatSerial(appointment.serialNumber),
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.heartRedLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'মিলিসেকেন্ড FCFS পদ্ধতিতে সংগৃহীত',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.heartRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Patient & Booking info table
                  _buildInfoRow(
                    icon: Icons.person_rounded,
                    label: 'রোগীর নাম:',
                    value: '${appointment.patientName} (${BengaliFormatter.toBengaliNumber(appointment.patientAge)} বছর, ${appointment.patientGender})',
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildInfoRow(
                    icon: Icons.phone_android_rounded,
                    label: 'মোবাইল নম্বর:',
                    value: appointment.patientPhone,
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildInfoRow(
                    icon: Icons.calendar_month_rounded,
                    label: 'তারিখ ও সময়:',
                    value: '${BengaliFormatter.formatDate(appointment.appointmentDate)}\n${appointment.slotTime}',
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildInfoRow(
                    icon: Icons.location_on_rounded,
                    label: 'চেম্বার:',
                    value: '${appointment.chamberName}\n${appointment.chamberLocation}',
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildInfoRow(
                    icon: Icons.timer_outlined,
                    label: 'বুকিং সময় (MS):',
                    value: exactTimeBengali,
                    valueColor: AppColors.primaryDark,
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'বন্ধ করুন',
                        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onViewHistory();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'বুকিং হিস্ট্রি',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
