import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../utils/app_colors.dart';
import '../utils/bengali_digits.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/slot_card.dart';
import '../widgets/serial_token_dialog.dart';

class BookingScreen extends StatefulWidget {
  final VoidCallback onNavigateToHistory;

  const BookingScreen({
    super.key,
    required this.onNavigateToHistory,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _problemController = TextEditingController();

  String _selectedGender = 'পুরুষ';
  String? _selectedSlotId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default select first available slot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppointmentProvider>();
      if (provider.slots.isNotEmpty) {
        setState(() {
          _selectedSlotId = provider.slots.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _handleBooking(AppointmentProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে একটি সময় স্লট নির্বাচন করুন।'),
          backgroundColor: AppColors.heartRed,
        ),
      );
      return;
    }

    final dateKey = provider.getDateKey(provider.selectedDate);
    if (provider.isSlotFull(dateKey, _selectedSlotId!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('আজকের জন্য এই স্লটের বুকিং পূর্ণ হয়ে গেছে! অন্য দিন বা স্লট বেছে নিন।'),
          backgroundColor: AppColors.heartRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await provider.bookAppointment(
      patientName: _nameController.text.trim(),
      patientPhone: _phoneController.text.trim(),
      patientAge: int.tryParse(_ageController.text.trim()) ?? 30,
      patientGender: _selectedGender,
      problemDescription: _problemController.text.trim(),
      date: provider.selectedDate,
      slotId: _selectedSlotId!,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result.isSuccess && result.appointment != null) {
      // Clear form
      _nameController.clear();
      _phoneController.clear();
      _ageController.clear();
      _problemController.clear();

      // Show VIP Digital Token Pass
      SerialTokenDialog.show(
        context,
        appointment: result.appointment!,
        onViewHistory: widget.onNavigateToHistory,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.heartRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final selectedDate = provider.selectedDate;
    final dateKey = provider.getDateKey(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('সিরিয়াল বুকিং'),
            Text(
              'ডা. হরিপদ (হৃদরোগ বিশেষজ্ঞ) • রংপুর',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'আমার বুকিং',
            icon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            onPressed: widget.onNavigateToHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Date Selector Bar
            DateSelectorBar(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                provider.setSelectedDate(date);
              },
            ),

            const SizedBox(height: 12),

            // Date Headline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'নির্বাচিত তারিখ: ${BengaliFormatter.formatDate(selectedDate)}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Slots Selection
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'সময় স্লট নির্বাচন করুন',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),

            ...provider.slots.map((slot) {
              final isFull = provider.isSlotFull(dateKey, slot.id);
              final bookedCount = provider.getBookedCount(dateKey, slot.id);
              final totalLimit = provider.getSlotLimit(dateKey, slot.id);
              final isSelected = _selectedSlotId == slot.id;

              return SlotCard(
                slot: slot,
                isSelected: isSelected,
                isFull: isFull,
                bookedCount: bookedCount,
                totalLimit: totalLimit,
                onTap: () {
                  setState(() {
                    _selectedSlotId = slot.id;
                  });
                },
              );
            }),

            const SizedBox(height: 20),

            // 3. Patient Details Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_outline_rounded, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'রোগীর তথ্য দিন',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Patient Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'রোগীর পূর্ণ নাম *',
                          hintText: 'যেমন: মো. করিমুল ইসলাম',
                          prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'রোগীর নাম অবশ্যই দিতে হবে';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Mobile Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'মোবাইল নম্বর (১১ ডিজিট) *',
                          hintText: 'যেমন: 017xxxxxxxx',
                          prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'মোবাইল নম্বর অবশ্যই দিতে হবে';
                          }
                          if (value.trim().length < 11) {
                            return 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Age & Gender Row
                      Row(
                        children: [
                          // Age
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'বয়স *',
                                hintText: 'যেমন: ৪৫',
                                prefixIcon: Icon(Icons.cake_outlined, color: AppColors.primary),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'বয়স দিন';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Gender Dropdown
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedGender,
                                  isExpanded: true,
                                  items: ['পুরুষ', 'মহিলা', 'অন্যান্য'].map((gender) {
                                    return DropdownMenuItem(
                                      value: gender,
                                      child: Text(
                                        gender,
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedGender = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Problem description (optional)
                      TextFormField(
                        controller: _problemController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'সমস্যার বিবরণ (ঐচ্ছিক)',
                          hintText: 'যেমন: বুকে ব্যথা, শ্বাসকষ্ট বা নিয়মিত চেকআপ',
                          prefixIcon: Icon(Icons.notes_rounded, color: AppColors.primary),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Instant Booking Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _handleBooking(provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bolt_rounded, color: Colors.amberAccent),
                                    SizedBox(width: 6),
                                    Text(
                                      'সিরিয়াল নিশ্চিত করুন (FCFS)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          '⚡ মিলিসেকেন্ড নির্ভুল সময় অনুসারে তাৎক্ষণিক সিরিয়াল বরাদ্দ হবে',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
