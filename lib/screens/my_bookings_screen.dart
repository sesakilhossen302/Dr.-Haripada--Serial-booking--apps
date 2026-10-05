import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../utils/app_colors.dart';
import '../utils/bengali_digits.dart';
import '../widgets/serial_token_dialog.dart';

class MyBookingsScreen extends StatelessWidget {
  final VoidCallback onBookNewPressed;

  const MyBookingsScreen({
    super.key,
    required this.onBookNewPressed,
  });

  void _showPhoneLookupDialog(BuildContext context, AppointmentProvider provider) {
    final controller = TextEditingController(text: provider.savedUserPhone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.phone_android_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'বুকিং খুঁজে বের করুন',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'যে মোবাইল নম্বর দিয়ে আপনি বুকিং করেছিলেন, সেটি দিন। আপনার সমস্ত সিরিয়াল টিকিট স্বয়ংক্রিয়ভাবে স্ক্রিনে চলে আসবে।',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '১১ ডিজিট মোবাইল নম্বর',
                hintText: 'যেমন: 017xxxxxxxx',
                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = controller.text.trim();
              if (phone.isNotEmpty) {
                provider.linkUserPhone(phone);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('আপনার মোবাইল নম্বরের বুকিং হিস্ট্রি সফলভাবে লোড হয়েছে!'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('খুঁজুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final bookings = provider.getUserAppointments();
    final currentRunning = provider.currentCallingSerial;
    final savedPhone = provider.savedUserPhone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার বুকিং হিস্ট্রি'),
        actions: [
          IconButton(
            tooltip: 'মোবাইল নম্বর দিয়ে বুকিং খুঁজুন',
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
            onPressed: () => _showPhoneLookupDialog(context, provider),
          ),
          IconButton(
            tooltip: 'নতুন বুকিং',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: onBookNewPressed,
          ),
        ],
      ),
      body: bookings.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'আপনার কোনো বুকিং পাওয়া যায়নি',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'এই ফোন থেকে এখনো কোনো সিরিয়াল নেওয়া হয়নি। আপনি কি পূর্বে অন্য ফোন বা নম্বরে বুকিং করেছিলেন?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onBookNewPressed,
                          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          label: const Text('নতুন বুকিং করুন'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showPhoneLookupDialog(context, provider),
                          icon: const Icon(Icons.phone_android_rounded, size: 16),
                          label: const Text('নম্বর দিয়ে খুঁজুন'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Live Queue Status Banner
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sensors_rounded, color: Colors.greenAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'আজকের চেম্বারের লাইভ অগ্রগতি',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            Row(
                              children: [
                                const Text(
                                  'বর্তমান রানিং সিরিয়াল: ',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  BengaliFormatter.formatSerial(currentRunning),
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Saved Phone Number Bar
                if (savedPhone != null && savedPhone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_android_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'সংযুক্ত মোবাইল: $savedPhone',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _showPhoneLookupDialog(context, provider),
                            child: const Text(
                              'নম্বর পরিবর্তন',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bookings List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final item = bookings[index];
                      return _buildBookingCard(context, item, currentRunning);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBookingCard(BuildContext context, AppointmentModel item, int currentRunning) {
    Color statusBg;
    Color statusText;
    IconData statusIcon;

    switch (item.status) {
      case AppointmentStatus.waiting:
        statusBg = AppColors.primarySurface;
        statusText = AppColors.primary;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case AppointmentStatus.inChamber:
        statusBg = AppColors.successLight;
        statusText = AppColors.successGreen;
        statusIcon = Icons.medical_services_rounded;
        break;
      case AppointmentStatus.completed:
        statusBg = const Color(0xFFF1F5F9);
        statusText = AppColors.textMuted;
        statusIcon = Icons.check_circle_rounded;
        break;
      case AppointmentStatus.cancelled:
        statusBg = AppColors.heartRedLight;
        statusText = AppColors.heartRed;
        statusIcon = Icons.cancel_rounded;
        break;
    }

    final isUpcoming = item.status == AppointmentStatus.waiting || item.status == AppointmentStatus.inChamber;
    final patientsAhead = item.serialNumber - currentRunning;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.status == AppointmentStatus.inChamber
              ? AppColors.successGreen
              : AppColors.border,
          width: item.status == AppointmentStatus.inChamber ? 1.8 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          SerialTokenDialog.show(
            context,
            appointment: item,
            onViewHistory: () {},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Serial Badge & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'সিরিয়াল নং: ',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          BengaliFormatter.formatSerial(item.serialNumber),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusText),
                        const SizedBox(width: 4),
                        Text(
                          item.status.titleBengali,
                          style: TextStyle(
                            color: statusText,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Patient Name & Age
              Text(
                'রোগী: ${item.patientName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'বয়স: ${BengaliFormatter.toBengaliNumber(item.patientAge)} বছর | লিঙ্গ: ${item.patientGender} | মোবাইল: ${item.patientPhone}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),

              // Date, Slot & Chamber
              Row(
                children: [
                  const Icon(Icons.event_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    BengaliFormatter.formatDate(item.appointmentDate),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${item.slotTime} (${item.chamberName})',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ],
              ),

              // Queue Proximity Hint if waiting
              if (isUpcoming && item.status == AppointmentStatus.waiting) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: patientsAhead > 0 ? AppColors.primarySurface : AppColors.heartRedLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    patientsAhead > 0
                        ? 'ℹ️ আপনার আগে আরও ${BengaliFormatter.toBengaliNumber(patientsAhead)} জন রোগী অপেক্ষমান আছেন'
                        : '⚡ আপনার সিরিয়াল প্রস্তুত, চেম্বারের সামনে উপস্থিত থাকুন',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: patientsAhead > 0 ? AppColors.primaryDark : AppColors.heartRed,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),
              // View Token link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    SerialTokenDialog.show(
                      context,
                      appointment: item,
                      onViewHistory: () {},
                    );
                  },
                  icon: const Icon(Icons.qr_code_rounded, size: 16, color: AppColors.primary),
                  label: const Text(
                    'ডিজিタル টোকেন দেখুন',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
