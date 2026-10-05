class BengaliFormatter {
  static const Map<String, String> _englishToBengaliDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static String toBengaliNumber(dynamic number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_englishToBengaliDigits[char] ?? char);
    }
    return buffer.toString();
  }

  static String formatSerial(int serial) {
    final padded = serial.toString().padLeft(2, '0');
    return toBengaliNumber(padded);
  }

  static String getBengaliDayName(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'শনিবার';
      case DateTime.sunday:
        return 'রবিবার';
      case DateTime.monday:
        return 'সোমবার';
      case DateTime.tuesday:
        return 'মঙ্গলবার';
      case DateTime.wednesday:
        return 'বুধবার';
      case DateTime.thursday:
        return 'বৃহস্পতিবার';
      case DateTime.friday:
        return 'শুক্রবার';
      default:
        return '';
    }
  }

  static String getBengaliMonthName(int month) {
    switch (month) {
      case 1:
        return 'জানুয়ারি';
      case 2:
        return 'ফেব্রুয়ারি';
      case 3:
        return 'মার্চ';
      case 4:
        return 'এপ্রিল';
      case 5:
        return 'মে';
      case 6:
        return 'জুন';
      case 7:
        return 'জুলাই';
      case 8:
        return 'আগস্ট';
      case 9:
        return 'সেপ্টেম্বর';
      case 10:
        return 'অক্টোবর';
      case 11:
        return 'নভেম্বর';
      case 12:
        return 'ডিসেম্বর';
      default:
        return '';
    }
  }

  static String getBengaliShortMonthName(int month) {
    switch (month) {
      case 1:
        return 'জানু';
      case 2:
        return 'ফেব';
      case 3:
        return 'মার্চ';
      case 4:
        return 'এপ্রিল';
      case 5:
        return 'মে';
      case 6:
        return 'জুন';
      case 7:
        return 'জুলাই';
      case 8:
        return 'আগস্ট';
      case 9:
        return 'সেপ্টে';
      case 10:
        return 'অক্টো';
      case 11:
        return 'নভে';
      case 12:
        return 'ডিসে';
      default:
        return '';
    }
  }

  static String formatDate(DateTime date) {
    final day = toBengaliNumber(date.day);
    final month = getBengaliMonthName(date.month);
    final year = toBengaliNumber(date.year);
    final dayName = getBengaliDayName(date.weekday);
    return '$dayName, $day $month $year';
  }

  static String formatShortDate(DateTime date) {
    final day = toBengaliNumber(date.day);
    final month = getBengaliShortMonthName(date.month);
    return '$day $month';
  }
}
