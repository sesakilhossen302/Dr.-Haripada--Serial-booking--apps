import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/bengali_digits.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isAuthenticated = true; // Auto-authenticated for frictionless demo presentation
  final _pinController = TextEditingController();
  DateTime _adminSelectedDate = DateTime.now();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showSetLimitDialog(BuildContext context, AppointmentProvider provider, String slotId, String slotName, int currentLimit) {
    final controller = TextEditingController(text: currentLimit.toString());
    final dateKey = provider.getDateKey(_adminSelectedDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'দৈনিক রোগী লিমিট নির্ধারণ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'স্লট: $slotName',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              'তারিখ: ${BengaliFormatter.formatDate(_adminSelectedDate)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'এই দিনে সর্বোচ্চ কতজন রোগী সিরিয়াল নিতে পারবেন?',
              style: TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'রোগী সংখ্যা (লিমিট)',
                hintText: 'যেমন: ২০ বা ৫০',
                prefixIcon: Icon(Icons.people_alt_outlined),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 20, 30, 50].map((preset) {
                return ActionChip(
                  label: Text('${BengaliFormatter.toBengaliNumber(preset)} জন'),
                  onPressed: () {
                    controller.text = preset.toString();
                  },
                );
              }).toList(),
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
              final newLimit = int.tryParse(controller.text.trim());
              if (newLimit != null && newLimit > 0) {
                provider.setSlotLimit(dateKey, slotId, newLimit);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$slotName এর লিমিট ${BengaliFormatter.toBengaliNumber(newLimit)} জনে আপডেট করা হয়েছে।'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('ডাক্তার / চেম্বার অ্যাডমিন')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person_rounded, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'চেম্বার অ্যাডমিন পিন কোড দিন',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('ডেমো পিন: 1234', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'PIN'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_pinController.text.trim() == '1234') {
                      setState(() {
                        _isAuthenticated = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ভুল পিন কোড!'), backgroundColor: AppColors.heartRed),
                      );
                    }
                  },
                  child: const Text('লগইন করুন'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final provider = context.watch<AppointmentProvider>();
    final dateKey = provider.getDateKey(_adminSelectedDate);
    final appointmentsForDate = provider.allAppointments
        .where((a) => a.dateKey == dateKey)
        .toList()
      ..sort((a, b) => a.bookedAt.compareTo(b.bookedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('চেম্বার অ্যাডমিন ও কন্ট্রোল ডেক্স'),
            Text(
              'ডা. হরিপদ • রংপুর চেম্বার কন্ট্রোলার',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'তারিখ পরিবর্তন',
            icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _adminSelectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() {
                  _adminSelectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Chamber Queue Controller Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over_rounded, color: Colors.amberAccent, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'লাইভ সিরিয়াল কলিং ডেক্স',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          BengaliFormatter.formatShortDate(_adminSelectedDate),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'বর্তমানে রুমে আছেন: ',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'সিরিয়াল ${BengaliFormatter.formatSerial(provider.currentCallingSerial)}',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            provider.callNextSerial();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('সিরিয়াল ${BengaliFormatter.formatSerial(provider.currentCallingSerial)} কে ডাকা হয়েছে।'),
                                backgroundColor: AppColors.successGreen,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryDark),
                          label: const Text(
                            'পরবর্তী রোগী ডাকুন (+১)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'সিরিয়াল রিসেট (০১)',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                        ),
                        icon: const Icon(Icons.restart_alt_rounded, color: Colors.white),
                        onPressed: () {
                          provider.setCurrentCallingSerial(1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Slot Capacity & Limits Controller
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'স্লট লিমিট ও সিট নিয়ন্ত্রণ',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  BengaliFormatter.formatShortDate(_adminSelectedDate),
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'ডাক্তার হরিপদ যতজন রোগী দেখতে চান (যেমন ২০ বা ৫০ জন), এখান থেকে লিমিট সেট করুন। নির্দিষ্ট সংখ্যা বুক হলে স্বয়ংক্রিয়ভাবে স্লট পূর্ণ দেখাবে।',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            ...provider.slots.map((slot) {
              final booked = provider.getBookedCount(dateKey, slot.id);
              final limit = provider.getSlotLimit(dateKey, slot.id);
              final isFull = booked >= limit;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFull ? AppColors.heartRed.withValues(alpha: 0.4) : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                slot.timeRange,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              if (isFull)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.heartRedLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'পূর্ণ',
                                    style: TextStyle(color: AppColors.heartRed, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slot.chamberName,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'বর্তমান বুকিং: ${BengaliFormatter.toBengaliNumber(booked)} জন / সর্বোচ্চ লিমিট: ${BengaliFormatter.toBengaliNumber(limit)} জন',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isFull ? AppColors.heartRed : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'লিমিট পরিবর্তন',
                      icon: const Icon(Icons.edit_note_rounded),
                      onPressed: () {
                        _showSetLimitDialog(context, provider, slot.id, slot.timeRange, limit);
                      },
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // 3. Real-Time Patient Booking Roster (Millisecond Precision)
            Row(
              children: [
                const Text(
                  'আজকের রোগীর তালিকা (FCFS সিরিয়াল)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'মোট: ${BengaliFormatter.toBengaliNumber(appointmentsForDate.length)} জন',
                    style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (appointmentsForDate.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'এই তারিখে এখনো কোনো বুকিং পাওয়া যায়নি।',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ...appointmentsForDate.map((apt) {
                final ms = apt.bookedAt.millisecond.toString().padLeft(3, '0');
                final sec = apt.bookedAt.second.toString().padLeft(2, '0');
                final min = apt.bookedAt.minute.toString().padLeft(2, '0');
                final hr = apt.bookedAt.hour.toString().padLeft(2, '0');
                final timeExact = '$hr:$min:$sec.$ms';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Big Serial Circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: apt.status == AppointmentStatus.inChamber
                                ? AppColors.successGreen
                                : AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              BengaliFormatter.formatSerial(apt.serialNumber),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: apt.status == AppointmentStatus.inChamber
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      apt.patientName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  // Status Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: apt.status == AppointmentStatus.inChamber
                                          ? AppColors.successLight
                                          : (apt.status == AppointmentStatus.completed
                                              ? const Color(0xFFF1F5F9)
                                              : AppColors.primarySurface),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      apt.status.titleBengali,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: apt.status == AppointmentStatus.inChamber
                                            ? AppColors.successGreen
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${apt.patientPhone} | ${BengaliFormatter.toBengaliNumber(apt.patientAge)} বছর (${apt.patientGender})',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'বুকিং সময়: $timeExact (FCFS টাইমস্ট্যাম্প)',
                                style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
                              ),
                              if (apt.problemDescription.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'সমস্যা: ${apt.problemDescription}',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textDark, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Quick status switch popup menu
                        PopupMenuButton<AppointmentStatus>(
                          icon: const Icon(Icons.more_vert_rounded, size: 20),
                          onSelected: (status) {
                            provider.updateStatus(apt.id, status);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: AppointmentStatus.waiting,
                              child: Text('অপেক্ষমান (Waiting)'),
                            ),
                            const PopupMenuItem(
                              value: AppointmentStatus.inChamber,
                              child: Text('ডাক্তারের কক্ষে (In Chamber)'),
                            ),
                            const PopupMenuItem(
                              value: AppointmentStatus.completed,
                              child: Text('সম্পন্ন (Completed)'),
                            ),
                            const PopupMenuItem(
                              value: AppointmentStatus.cancelled,
                              child: Text('বাতিল (Cancelled)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
