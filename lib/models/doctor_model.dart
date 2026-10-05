class DoctorModel {
  final String name;
  final String englishName;
  final String title;
  final String degrees;
  final String designation;
  final String experience;
  final int totalPatients;
  final double rating;
  final int totalReviews;
  final String bio;
  final String consultationFee;
  final String followUpFee;
  final String visitingDays;
  final String visitingHours;
  final String helpline;
  final List<ChamberInfo> chambers;

  const DoctorModel({
    required this.name,
    required this.englishName,
    required this.title,
    required this.degrees,
    required this.designation,
    required this.experience,
    required this.totalPatients,
    required this.rating,
    required this.totalReviews,
    required this.bio,
    required this.consultationFee,
    required this.followUpFee,
    required this.visitingDays,
    required this.visitingHours,
    required this.helpline,
    required this.chambers,
  });

  static DoctorModel defaultDoctor() {
    return const DoctorModel(
      name: 'ডা. হরিপদ',
      englishName: 'Dr. Haripada',
      title: 'হৃদরোগ, উচ্চ রক্তচাপ ও কার্ডিওলজি বিশেষজ্ঞ এবং সার্জন',
      degrees: 'এমবিবিএস, বিসিএস (স্বাস্থ্য), এফসিপিএস (মেডিসিন), এমডি (কার্ডিওলজি)',
      designation: 'সিনিয়র কার্ডিওলজিস্ট ও হৃদরোগ সার্জন, রংপুর',
      experience: '১৫+ বছর',
      totalPatients: 14500,
      rating: 4.9,
      totalReviews: 1240,
      bio: 'ডা. হরিপদ উত্তরবঙ্গের অন্যতম শীর্ষস্থানীয় হৃদরোগ ও কার্ডিওলজি বিশেষজ্ঞ। জটিল হৃদরোগ, হার্ট ব্লক, উচ্চ রক্তচাপ, হার্ট ফেইলিউর এবং ইন্টারভেনশনাল কার্ডিওলজিতে তাঁর রয়েছে দীর্ঘ ১৫ বছরের সফল ক্লিনিক্যাল ও সার্জিকেল অভিজ্ঞতা। রোগীদের সঠিক রোগ নির্ণয় এবং আন্তরিক সেবায় তিনি সর্বজনবিদিত।',
      consultationFee: '৳ ৮০০',
      followUpFee: '৳ ৫০০',
      visitingDays: 'শনিবার - বৃহস্পতিবার (শুক্রবার চেম্বার বন্ধ)',
      visitingHours: 'বিকাল ৪:০০ টা – রাত ৯:০০ টা',
      helpline: '০১৭৫০০০০০০০',
      chambers: [
        ChamberInfo(
          id: 'chamber_central',
          name: 'সেন্ট্রাল স্পেশালাইজড হাসপাতাল ও হার্ট সেন্টার',
          location: 'জেল রোড, ধাপ মোড়, রংপুর',
          contactNumber: '০১৭৫২-১১২২৩৩',
          availableTime: 'বিকাল ৪:০০ টা - বিকাল ৬:৩০ টা',
        ),
        ChamberInfo(
          id: 'chamber_popular',
          name: 'পপুলার ডায়াগনস্টিক সেন্টার',
          location: 'ধাপ, জেল রোড ক্রসিং, রংপুর',
          contactNumber: '০১৭৯৯-৪৪৭৭৮৮',
          availableTime: 'সন্ধ্যা ৭:০০ টা - রাত ৯:৩০ টা',
        ),
      ],
    );
  }
}

class ChamberInfo {
  final String id;
  final String name;
  final String location;
  final String contactNumber;
  final String availableTime;

  const ChamberInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.contactNumber,
    required this.availableTime,
  });
}
