class SlotModel {
  final String id;
  final String timeRange; // e.g. "বিকাল ৪:০০ – ৫:০০"
  final String chamberId;
  final String chamberName; // e.g. "সেন্ট্রাল হাসপাতাল"
  final String location;
  final int defaultLimit; // e.g. 20 patients
  final bool isAvailable; // Admin can toggle active/off

  const SlotModel({
    required this.id,
    required this.timeRange,
    required this.chamberId,
    required this.chamberName,
    required this.location,
    required this.defaultLimit,
    this.isAvailable = true,
  });

  SlotModel copyWith({
    String? id,
    String? timeRange,
    String? chamberId,
    String? chamberName,
    String? location,
    int? defaultLimit,
    bool? isAvailable,
  }) {
    return SlotModel(
      id: id ?? this.id,
      timeRange: timeRange ?? this.timeRange,
      chamberId: chamberId ?? this.chamberId,
      chamberName: chamberName ?? this.chamberName,
      location: location ?? this.location,
      defaultLimit: defaultLimit ?? this.defaultLimit,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  static List<SlotModel> getInitialSlots() {
    return const [
      SlotModel(
        id: 'slot_1',
        timeRange: 'বিকাল ৪:০০ – ৫:০০',
        chamberId: 'chamber_central',
        chamberName: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল',
        location: 'জেল রোড, ধাপ, রংপুর',
        defaultLimit: 20,
        isAvailable: true,
      ),
      SlotModel(
        id: 'slot_2',
        timeRange: 'বিকাল ৫:০০ – ৬:০০',
        chamberId: 'chamber_central',
        chamberName: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল',
        location: 'জেল রোড, ধাপ, রংপুর',
        defaultLimit: 20,
        isAvailable: true,
      ),
      SlotModel(
        id: 'slot_3',
        timeRange: 'সন্ধ্যা ৭:০০ – ৮:০০',
        chamberId: 'chamber_popular',
        chamberName: 'পপুলার ডায়াগনস্টিক সেন্টার',
        location: 'ধাপ মোড়, জেল রোড ক্রসিং, রংপুর',
        defaultLimit: 25,
        isAvailable: true,
      ),
      SlotModel(
        id: 'slot_4',
        timeRange: 'রাত ৮:০০ – ৯:০০',
        chamberId: 'chamber_popular',
        chamberName: 'পপুলার ডায়াগনস্টিক সেন্টার',
        location: 'ধাপ মোড়, জেল রোড ক্রসিং, রংপুর',
        defaultLimit: 25,
        isAvailable: true,
      ),
    ];
  }
}
