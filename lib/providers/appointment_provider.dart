import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor_model.dart';
import '../models/slot_model.dart';
import '../models/appointment_model.dart';

class BookingResult {
  final bool isSuccess;
  final String message;
  final AppointmentModel? appointment;

  const BookingResult({
    required this.isSuccess,
    required this.message,
    this.appointment,
  });

  factory BookingResult.success(AppointmentModel appointment) {
    return BookingResult(
      isSuccess: true,
      message: 'অভিনন্দন! আপনার সিরিয়াল সফলভাবে নিশ্চিত হয়েছে।',
      appointment: appointment,
    );
  }

  factory BookingResult.failure(String message) {
    return BookingResult(
      isSuccess: false,
      message: message,
    );
  }
}

class AppointmentProvider extends ChangeNotifier {
  late DoctorModel _doctor;
  late List<SlotModel> _slots;
  final List<AppointmentModel> _appointments = [];
  
  // Custom slot capacity limit override: key = "${dateKey}_${slotId}" -> limit
  final Map<String, int> _customLimits = {};

  // Device-level persistence: Only show bookings made from THIS device or phone number
  final List<String> _myBookedIds = [];
  String? _savedUserPhone;
  String? _savedUserName;

  // Current calling serial number for live queue
  int _currentCallingSerial = 3;

  // Selected date in booking screen
  DateTime _selectedDate = DateTime.now();

  AppointmentProvider() {
    _initData();
    _initFirestore();
    _loadUserPreferences();
  }

  DoctorModel get doctor => _doctor;
  List<SlotModel> get slots => _slots;
  List<AppointmentModel> get allAppointments => List.unmodifiable(_appointments);
  int get currentCallingSerial => _currentCallingSerial;
  DateTime get selectedDate => _selectedDate;
  String? get savedUserPhone => _savedUserPhone;
  String? get savedUserName => _savedUserName;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void _initData() {
    _doctor = DoctorModel.defaultDoctor();
    _slots = SlotModel.getInitialSlots();

    // Pre-populate with realistic demo appointments for today
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    _appointments.addAll([
      AppointmentModel(
        id: 'apt_demo_1',
        serialNumber: 1,
        patientName: 'মো. আব্দুল কাদের',
        patientPhone: '০১৭২২-৯৮৭৬৫৪',
        patientAge: 58,
        patientGender: 'পুরুষ',
        problemDescription: 'বুকে চিনচিন ব্যথা ও শ্বাসকষ্ট',
        dateKey: todayKey,
        appointmentDate: now,
        slotId: 'slot_1',
        slotTime: 'বিকাল ৪:০০ – ৫:০০',
        chamberName: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল',
        chamberLocation: 'জেল রোড, ধাপ, রংপুর',
        bookedAt: now.subtract(const Duration(minutes: 125, milliseconds: 320)),
        status: AppointmentStatus.completed,
        tokenCode: 'HP-${todayKey.replaceAll('-', '')}-001',
      ),
      AppointmentModel(
        id: 'apt_demo_2',
        serialNumber: 2,
        patientName: 'বেগম রাজিয়া সুলতানা',
        patientPhone: '০১৮১৯-৪৫৫৬৬৭',
        patientAge: 49,
        patientGender: 'মহিলা',
        problemDescription: 'উচ্চ রক্তচাপ ও মাথা ঘোরানো',
        dateKey: todayKey,
        appointmentDate: now,
        slotId: 'slot_1',
        slotTime: 'বিকাল ৪:০০ – ৫:০০',
        chamberName: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল',
        chamberLocation: 'জেল রোড, ধাপ, রংপুর',
        bookedAt: now.subtract(const Duration(minutes: 110, milliseconds: 780)),
        status: AppointmentStatus.completed,
        tokenCode: 'HP-${todayKey.replaceAll('-', '')}-002',
      ),
      AppointmentModel(
        id: 'apt_demo_3',
        serialNumber: 3,
        patientName: 'সুশীল কুমার রায়',
        patientPhone: '০১৭৫১-৩৩৪২৫৬',
        patientAge: 62,
        patientGender: 'পুরুষ',
        problemDescription: 'হার্টে রিং পরানো, নিয়মিত ফলোআপ চেকআপ',
        dateKey: todayKey,
        appointmentDate: now,
        slotId: 'slot_1',
        slotTime: 'বিকাল ৪:০০ – ৫:০০',
        chamberName: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল',
        chamberLocation: 'জেল রোড, ধাপ, রংপুর',
        bookedAt: now.subtract(const Duration(minutes: 95, milliseconds: 120)),
        status: AppointmentStatus.inChamber,
        tokenCode: 'HP-${todayKey.replaceAll('-', '')}-003',
      ),
      AppointmentModel(
        id: 'apt_demo_4',
        serialNumber: 4,
        patientName: 'আফসানা মিমি',
        patientPhone: '০১৬২৪-১১২২৩৩',
        patientAge: 35,
        patientGender: 'মহিলা',
        problemDescription: 'বুক ধড়ফড় করা ও দুর্বলতা',
        dateKey: todayKey,
        appointmentDate: now,
        slotId: 'slot_1',
        slotTime: 'বিকাল ৪:০০ – ৫:০০',
        chamberName: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল',
        chamberLocation: 'জেল রোড, ধাপ, রংপুর',
        bookedAt: now.subtract(const Duration(minutes: 80, milliseconds: 640)),
        status: AppointmentStatus.waiting,
        tokenCode: 'HP-${todayKey.replaceAll('-', '')}-004',
      ),
      AppointmentModel(
        id: 'apt_demo_5',
        serialNumber: 5,
        patientName: 'তানভীর হাসান',
        patientPhone: '০১৭৭৮-০০৯৯৮৮',
        patientAge: 42,
        patientGender: 'পুরুষ',
        problemDescription: 'ইসিজি ও ইকো রিপোর্ট দেখানো',
        dateKey: todayKey,
        appointmentDate: now,
        slotId: 'slot_1',
        slotTime: 'বিকাল ৪:০০ – ৫:০০',
        chamberName: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল',
        chamberLocation: 'জেল রোড, ধাপ, রংপুর',
        bookedAt: now.subtract(const Duration(minutes: 65, milliseconds: 210)),
        status: AppointmentStatus.waiting,
        tokenCode: 'HP-${todayKey.replaceAll('-', '')}-005',
      ),
    ]);
  }

  // Helper to construct date key YYYY-MM-DD
  String getDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Get active appointments for a specific date and slot
  List<AppointmentModel> getAppointmentsForSlot(String dateKey, String slotId) {
    return _appointments
        .where((apt) => apt.dateKey == dateKey && apt.slotId == slotId && apt.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.bookedAt.compareTo(b.bookedAt)); // Millisecond precision sort
  }

  // Count booked appointments
  int getBookedCount(String dateKey, String slotId) {
    return _appointments
        .where((apt) => apt.dateKey == dateKey && apt.slotId == slotId && apt.status != AppointmentStatus.cancelled)
        .length;
  }

  // Capacity limit for a slot
  int getSlotLimit(String dateKey, String slotId) {
    final customKey = "${dateKey}_$slotId";
    if (_customLimits.containsKey(customKey)) {
      return _customLimits[customKey]!;
    }
    final slot = _slots.firstWhere((s) => s.id == slotId, orElse: () => _slots.first);
    return slot.defaultLimit;
  }

  // Is slot full?
  bool isSlotFull(String dateKey, String slotId) {
    final booked = getBookedCount(dateKey, slotId);
    final limit = getSlotLimit(dateKey, slotId);
    return booked >= limit;
  }

  // Remaining seats
  int getRemainingSeats(String dateKey, String slotId) {
    final booked = getBookedCount(dateKey, slotId);
    final limit = getSlotLimit(dateKey, slotId);
    final remaining = limit - booked;
    return remaining > 0 ? remaining : 0;
  }

  // FCFS Millisecond-Precision Booking Engine
  Future<BookingResult> bookAppointment({
    required String patientName,
    required String patientPhone,
    required int patientAge,
    required String patientGender,
    required String problemDescription,
    required DateTime date,
    required String slotId,
  }) async {
    // Artificial slight async delay to simulate network & FCFS queue latching
    await Future.delayed(const Duration(milliseconds: 300));

    final dateKey = getDateKey(date);

    // 1. Capacity Exhaustion check
    if (isSlotFull(dateKey, slotId)) {
      return BookingResult.failure(
        'দুঃখিত! আজকের জন্য এই স্লটের সকল সিরিয়াল বুকিং সম্পন্ন হয়ে গেছে। অনুগ্রহ করে অন্য দিন বা অন্য স্লট বেছে নিন।',
      );
    }

    // 2. Fetch slot details
    final slot = _slots.firstWhere(
      (s) => s.id == slotId,
      orElse: () => _slots.first,
    );

    if (!slot.isAvailable) {
      return BookingResult.failure(
        'এই স্লটটি বর্তমানে সাময়িকভাবে বন্ধ রয়েছে। অনুগ্রহ করে অন্য স্লট নির্বাচন করুন।',
      );
    }

    // 3. Millisecond capture for FCFS
    final exactBookedAt = DateTime.now();

    // 4. Calculate next serial number for this date and slot
    final existingSlotAppointments = getAppointmentsForSlot(dateKey, slotId);
    final nextSerial = existingSlotAppointments.length + 1;

    final token = 'HP-${dateKey.replaceAll('-', '')}-${nextSerial.toString().padLeft(3, '0')}';

    final newAppointment = AppointmentModel(
      id: 'apt_${DateTime.now().microsecondsSinceEpoch}',
      serialNumber: nextSerial,
      patientName: patientName,
      patientPhone: patientPhone,
      patientAge: patientAge,
      patientGender: patientGender,
      problemDescription: problemDescription,
      dateKey: dateKey,
      appointmentDate: date,
      slotId: slotId,
      slotTime: slot.timeRange,
      chamberName: slot.chamberName,
      chamberLocation: slot.location,
      bookedAt: exactBookedAt,
      status: AppointmentStatus.waiting,
      tokenCode: token,
    );

    _appointments.add(newAppointment);
    _myBookedIds.add(newAppointment.id);
    _savedUserPhone = patientPhone;
    _savedUserName = patientName;
    _saveUserPreferences();
    notifyListeners();

    // Real-time Cloud Firestore Sync
    try {
      FirebaseFirestore.instance
          .collection('appointments')
          .doc(newAppointment.id)
          .set(newAppointment.toJson())
          .catchError((e) {
        debugPrint('Firestore push error: $e');
      });
    } catch (e) {
      debugPrint('Firestore write error: $e');
    }

    return BookingResult.success(newAppointment);
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('my_booked_ids') ?? [];
      _myBookedIds.clear();
      _myBookedIds.addAll(ids);
      _savedUserPhone = prefs.getString('saved_user_phone');
      _savedUserName = prefs.getString('saved_user_name');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user prefs: $e');
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('my_booked_ids', _myBookedIds);
      if (_savedUserPhone != null) {
        await prefs.setString('saved_user_phone', _savedUserPhone!);
      }
      if (_savedUserName != null) {
        await prefs.setString('saved_user_name', _savedUserName!);
      }
    } catch (e) {
      debugPrint('Error saving user prefs: $e');
    }
  }

  // Link mobile number manually or switch phone number
  Future<void> linkUserPhone(String phone) async {
    _savedUserPhone = phone.trim();
    await _saveUserPreferences();
    notifyListeners();
  }

  void _initFirestore() {
    try {
      // 1. Real-time stream of all appointments
      FirebaseFirestore.instance
          .collection('appointments')
          .snapshots()
          .listen((snapshot) {
        bool changed = false;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          try {
            final apt = AppointmentModel.fromJson(data);
            final existingIdx = _appointments.indexWhere((a) => a.id == apt.id);
            if (existingIdx != -1) {
              _appointments[existingIdx] = apt;
              changed = true;
            } else {
              _appointments.add(apt);
              changed = true;
            }
          } catch (e) {
            debugPrint('Error parsing firestore appointment: $e');
          }
        }
        if (changed) {
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('Firestore appointments listener error: $e');
      });

      // 2. Real-time stream of live queue serial
      FirebaseFirestore.instance
          .collection('settings')
          .doc('queue')
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('currentSerial')) {
            final serial = data['currentSerial'];
            if (serial is int && serial != _currentCallingSerial) {
              _currentCallingSerial = serial;
              notifyListeners();
            }
          }
        }
      }, onError: (e) {
        debugPrint('Firestore queue listener error: $e');
      });

      // 3. Real-time stream of custom slot limits
      FirebaseFirestore.instance
          .collection('settings')
          .doc('limits')
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          data.forEach((key, val) {
            if (val is int) {
              _customLimits[key] = val;
            }
          });
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('Firestore limits listener error: $e');
      });
    } catch (e) {
      debugPrint('Firestore init error: $e');
    }
  }

  // User's appointments list - Scoped strictly to THIS user's bookings
  List<AppointmentModel> getUserAppointments() {
    final list = _appointments.where((apt) {
      // 1. If this exact appointment was booked from this phone
      if (_myBookedIds.contains(apt.id)) return true;

      // 2. If phone number matches the user's saved mobile number
      if (_savedUserPhone != null && _savedUserPhone!.trim().isNotEmpty) {
        final cleanUser = _savedUserPhone!.replaceAll(RegExp(r'[^0-9]'), '');
        final cleanApt = apt.patientPhone.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanUser.length >= 10 && cleanApt.endsWith(cleanUser.substring(cleanUser.length - 10))) {
          return true;
        }
      }
      return false;
    }).toList();

    list.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    return list;
  }

  // Admin: Update slot limit (e.g. change limit to 20, 30, 50, 100)
  void setSlotLimit(String dateKey, String slotId, int newLimit) {
    final customKey = "${dateKey}_$slotId";
    _customLimits[customKey] = newLimit;
    notifyListeners();
  }

  // Admin: Toggle slot active/inactive
  void toggleSlotActive(String slotId, bool isAvailable) {
    final index = _slots.indexWhere((s) => s.id == slotId);
    if (index != -1) {
      _slots[index] = _slots[index].copyWith(isAvailable: isAvailable);
      notifyListeners();
    }
  }

  // Admin: Update status of an appointment
  void updateStatus(String appointmentId, AppointmentStatus newStatus) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  // Admin: Call next patient
  void callNextSerial() {
    _currentCallingSerial++;
    // Update the appointment with this serial to 'inChamber'
    final now = DateTime.now();
    final todayKey = getDateKey(now);
    final inChamberIdx = _appointments.indexWhere(
      (a) => a.dateKey == todayKey && a.serialNumber == _currentCallingSerial,
    );
    if (inChamberIdx != -1) {
      _appointments[inChamberIdx] = _appointments[inChamberIdx].copyWith(
        status: AppointmentStatus.inChamber,
      );
    }
    // Mark previous serial as completed
    final prevIdx = _appointments.indexWhere(
      (a) => a.dateKey == todayKey && a.serialNumber == (_currentCallingSerial - 1),
    );
    if (prevIdx != -1) {
      _appointments[prevIdx] = _appointments[prevIdx].copyWith(
        status: AppointmentStatus.completed,
      );
    }
    notifyListeners();
  }

  void setCurrentCallingSerial(int serial) {
    _currentCallingSerial = serial;
    notifyListeners();
  }
}
