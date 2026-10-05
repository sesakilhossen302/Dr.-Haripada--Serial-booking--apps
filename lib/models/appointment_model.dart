enum AppointmentStatus {
  waiting,     // সিরিয়াল অনুযায়ী অপেক্ষমান
  inChamber,   // ডাক্তারের রুমে চলমান
  completed,   // চিকিৎসা সম্পন্ন
  cancelled,   // বাতিল
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get titleBengali {
    switch (this) {
      case AppointmentStatus.waiting:
        return 'অপেক্ষমান';
      case AppointmentStatus.inChamber:
        return 'ডাক্তারের কক্ষে';
      case AppointmentStatus.completed:
        return 'সম্পন্ন';
      case AppointmentStatus.cancelled:
        return 'বাতিল';
    }
  }
}

class AppointmentModel {
  final String id;
  final int serialNumber; // 1, 2, 3 ...
  final String patientName;
  final String patientPhone;
  final int patientAge;
  final String patientGender; // পুরুষ / মহিলা / অন্যান্য
  final String problemDescription;
  final String dateKey; // YYYY-MM-DD
  final DateTime appointmentDate;
  final String slotId;
  final String slotTime;
  final String chamberName;
  final String chamberLocation;
  final DateTime bookedAt; // Millisecond precision timestamp
  final AppointmentStatus status;
  final String tokenCode;

  const AppointmentModel({
    required this.id,
    required this.serialNumber,
    required this.patientName,
    required this.patientPhone,
    required this.patientAge,
    required this.patientGender,
    required this.problemDescription,
    required this.dateKey,
    required this.appointmentDate,
    required this.slotId,
    required this.slotTime,
    required this.chamberName,
    required this.chamberLocation,
    required this.bookedAt,
    required this.status,
    required this.tokenCode,
  });

  AppointmentModel copyWith({
    String? id,
    int? serialNumber,
    String? patientName,
    String? patientPhone,
    int? patientAge,
    String? patientGender,
    String? problemDescription,
    String? dateKey,
    DateTime? appointmentDate,
    String? slotId,
    String? slotTime,
    String? chamberName,
    String? chamberLocation,
    DateTime? bookedAt,
    AppointmentStatus? status,
    String? tokenCode,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      problemDescription: problemDescription ?? this.problemDescription,
      dateKey: dateKey ?? this.dateKey,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      slotId: slotId ?? this.slotId,
      slotTime: slotTime ?? this.slotTime,
      chamberName: chamberName ?? this.chamberName,
      chamberLocation: chamberLocation ?? this.chamberLocation,
      bookedAt: bookedAt ?? this.bookedAt,
      status: status ?? this.status,
      tokenCode: tokenCode ?? this.tokenCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serialNumber': serialNumber,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'problemDescription': problemDescription,
      'dateKey': dateKey,
      'appointmentDate': appointmentDate.toIso8601String(),
      'slotId': slotId,
      'slotTime': slotTime,
      'chamberName': chamberName,
      'chamberLocation': chamberLocation,
      'bookedAt': bookedAt.toIso8601String(),
      'status': status.name,
      'tokenCode': tokenCode,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      serialNumber: json['serialNumber'] as int,
      patientName: json['patientName'] as String,
      patientPhone: json['patientPhone'] as String,
      patientAge: json['patientAge'] as int,
      patientGender: json['patientGender'] as String,
      problemDescription: json['problemDescription'] as String? ?? '',
      dateKey: json['dateKey'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      slotId: json['slotId'] as String,
      slotTime: json['slotTime'] as String,
      chamberName: json['chamberName'] as String,
      chamberLocation: json['chamberLocation'] as String,
      bookedAt: DateTime.parse(json['bookedAt'] as String),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.waiting,
      ),
      tokenCode: json['tokenCode'] as String,
    );
  }
}
