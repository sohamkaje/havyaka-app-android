import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../data/schedule_data_2026.dart';
import '../theme/design_system.dart';

enum EventTag {
  vedic('Vedic'),
  cultural('Cultural'),
  social('Social'),
  ceremony('Ceremony'),
  meal('Meal'),
  concert('Concert'),
  meeting('Meeting'),
  youth('Youth'),
  sports('Sports');

  const EventTag(this.label);
  final String label;

  Color get backgroundColor {
    switch (this) {
      case EventTag.vedic:
        return HAAColors.vedicBg;
      case EventTag.cultural:
        return HAAColors.culturalBg;
      case EventTag.social:
        return HAAColors.socialBg;
      case EventTag.ceremony:
        return HAAColors.ceremonyBg;
      case EventTag.meal:
        return const Color(0xFFF1EFE8);
      case EventTag.concert:
        return HAAColors.culturalBg;
      case EventTag.meeting:
        return HAAColors.ceremonyBg;
      case EventTag.youth:
        return const Color(0xFFE8F4FD);
      case EventTag.sports:
        return const Color(0xFFE8F8F0);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case EventTag.vedic:
        return HAAColors.vedicFg;
      case EventTag.cultural:
        return HAAColors.culturalFg;
      case EventTag.social:
        return HAAColors.socialFg;
      case EventTag.ceremony:
        return HAAColors.ceremonyFg;
      case EventTag.meal:
        return const Color(0xFF4A4030);
      case EventTag.concert:
        return HAAColors.culturalFg;
      case EventTag.meeting:
        return HAAColors.ceremonyFg;
      case EventTag.youth:
        return const Color(0xFF1565A8);
      case EventTag.sports:
        return const Color(0xFF166E3F);
    }
  }

  IconData get icon {
    switch (this) {
      case EventTag.vedic:
        return Icons.local_fire_department;
      case EventTag.cultural:
        return Icons.theater_comedy;
      case EventTag.social:
        return Icons.groups;
      case EventTag.ceremony:
        return Icons.star;
      case EventTag.meal:
        return Icons.restaurant;
      case EventTag.concert:
        return Icons.music_note;
      case EventTag.meeting:
        return Icons.people;
      case EventTag.youth:
        return Icons.directions_run;
      case EventTag.sports:
        return Icons.sports_tennis;
    }
  }
}

class ScheduleEvent {
  ScheduleEvent({
    required this.time,
    required this.title,
    this.kannada,
    required this.tag,
    required this.details,
    required this.icon,
    this.chapter,
    this.venue = 'Ahichhatra Auditorium',
    this.isHighlight = false,
  });

  final String time;
  final String title;
  final String? kannada;
  final EventTag tag;
  final String details;
  final String icon;
  final String? chapter;
  final String venue;
  final bool isHighlight;

  String get locationAddress {
    switch (venue) {
      case 'Play N Thrive Club':
      case 'Play N Thrive Club, Naperville':
        return '808 S Route 59, Ste 120, Naperville, IL 60540';
      case 'Chicago':
        return 'Chicago, IL';
      default:
        return 'Rosary College Prep · 901 N Edgelawn Dr, Aurora, IL 60506';
    }
  }

  bool get isOffSite {
    return venue == 'Play N Thrive Club' ||
        venue == 'Play N Thrive Club, Naperville' ||
        venue == 'Chicago';
  }
}

class ConventionDay {
  ConventionDay({
    required this.shortDay,
    required this.fullDate,
    required this.monthDay,
    required this.calendarDay,
    required this.events,
  });

  final String shortDay;
  final String fullDate;
  final String monthDay;
  final int calendarDay;
  final List<ScheduleEvent> events;
}

enum LocationCategory {
  all('All'),
  venue('Venue'),
  hotels('Hotels'),
  nearby('Nearby'),
  food('Food & Grocery'),
  sports('Sports & Activities');

  const LocationCategory(this.label);
  final String label;

  IconData get icon {
    switch (this) {
      case LocationCategory.all:
        return Icons.map;
      case LocationCategory.venue:
        return Icons.account_balance;
      case LocationCategory.hotels:
        return Icons.hotel;
      case LocationCategory.nearby:
        return Icons.star;
      case LocationCategory.food:
        return Icons.eco;
      case LocationCategory.sports:
        return Icons.sports_tennis;
    }
  }
}

class ConventionLocation {
  ConventionLocation({
    required this.name,
    required this.subtitle,
    required this.address,
    required this.category,
    required this.coordinate,
    required this.detail,
    required this.accentColor,
    required this.icon,
    this.distanceNote,
  });

  final String name;
  final String subtitle;
  final String address;
  final LocationCategory category;
  final LatLng coordinate;
  final String detail;
  final Color accentColor;
  final IconData icon;
  final String? distanceNote;
}

enum PhotoMediaType { image, video }

class PhotosLimits {
  static const maxUploadBytes = 45 * 1024 * 1024;
  static int get maxUploadMB => maxUploadBytes ~/ (1024 * 1024);

  static String? validateFileSize(int byteCount) {
    if (byteCount <= 0) return 'Could not read the selected file.';
    if (byteCount > maxUploadBytes) {
      final fileMB = byteCount / (1024 * 1024);
      return 'This file is ${fileMB.toStringAsFixed(1)} MB. The maximum allowed size is $maxUploadMB MB. Please choose a smaller photo or video.';
    }
    return null;
  }

  static String formattedSize(int byteCount) {
    final mb = byteCount / (1024 * 1024);
    return mb >= 0.1
        ? '${mb.toStringAsFixed(1)} MB'
        : '${(byteCount / 1024).round()} KB';
  }
}

class StarAttraction {
  const StarAttraction({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    this.kannada,
    required this.iconColor,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String? kannada;
  final Color iconColor;

  static const highlights = [
    StarAttraction(
      id: 'opening',
      icon: Icons.flag,
      title: 'Grand Opening Ceremony',
      subtitle: 'Opening procession & formal ceremony',
      description:
          'The official start of the 21st Biennial Convention with a festive procession, invocation dance, Veda Ghosha, addresses by HAA leadership and chief guest Vishweshwar Bhat, the HAA 10-year vision, sponsor recognition, and the convention theme song.',
      kannada: 'ಉತ್ಸವ ಮೆರವಣಿಗೆ ಮತ್ತು ಉದ್ಘಾಟನಾ ಸಮಾರಂಭ',
      iconColor: HAAColors.orange,
    ),
    StarAttraction(
      id: 'anuradha',
      icon: Icons.mic,
      title: 'Anuradha Bhat & Team — Live',
      subtitle: 'Celebrated playback singer from India',
      description:
          'A special musical night featuring celebrated playback singer Anuradha Bhat and accompanying artists from India — an evening of live Kannada film and classical favorites.',
      kannada: 'ಅನುರಾಧಾ ಭಟ್ ಮತ್ತು ತಂಡದ ಸಂಗೀತ ರಾತ್ರಿ',
      iconColor: HAAColors.orange,
    ),
    StarAttraction(
      id: 'swami',
      icon: Icons.auto_awesome,
      title: 'Swami Aparajitananda',
      subtitle: 'Intelligent Living & satsang',
      description:
          'Intelligent Living by Swami Aparajitananda on Saturday morning, followed by a breakout-room satsang and Q&A session for deeper reflection and community questions.',
      kannada: 'ಸ್ವಾಮಿ ಅಪರಾಜಿತಾನಂದರ ಆಧ್ಯಾತ್ಮಿಕ ಪ್ರವಚನ',
      iconColor: HAAColors.gold,
    ),
    StarAttraction(
      id: 'maya-leela',
      icon: Icons.accessibility_new,
      title: 'Maya Leela — Youth Dance Production',
      subtitle: 'Dance drama by all chapter youth',
      description:
          'A grand dance drama production bringing together youth from HAA chapters across North America — a highlight of Friday evening\'s cultural program in the Ahichhatra Auditorium.',
      kannada: 'ಮಾಯಾ ಲೀಲಾ — ಯುವ ನೃತ್ಯ ನಿರೂಪಣೆ',
      iconColor: HAAColors.orange,
    ),
    StarAttraction(
      id: 'hima-maya',
      icon: Icons.theater_comedy,
      title: 'Hima Maya — Dance Production',
      subtitle: 'Acharya Performing Arts Academy',
      description:
          'A dance drama production by Acharya Performing Arts Academy, presenting the Frozen story in Bharatanatyam dance drama style — one of Saturday morning\'s standout cultural performances.',
      kannada: 'ಹಿಮ ಮಾಯಾ — ನೃತ್ಯ ನಿರೂಪಣೆ',
      iconColor: HAAColors.gold,
    ),
    StarAttraction(
      id: 'youth-symphony',
      icon: Icons.queue_music,
      title: 'Youth Symphony',
      subtitle: 'All-chapter youth musical presentation',
      description:
          'A special musical presentation bringing together talented youth from HAA chapters across North America — a showcase of the next generation of Havyaka artists.',
      kannada: 'ಯುವ ಸಿಮ್ಫನಿ',
      iconColor: HAAColors.gold,
    ),
    StarAttraction(
      id: 'jugalbandi',
      icon: Icons.music_note,
      title: 'Jugalbandi of Music',
      subtitle: 'Vinayak Hegde & team',
      description:
          'A musical jugalbandi featuring Vinayak Hegde and team — an evening of collaborative classical performance and virtuoso interplay in the Ahichhatra Auditorium.',
      kannada: 'ಸಂಗೀತ ಜುಗಲ್ಬಂದಿ',
      iconColor: HAAColors.orange,
    ),
    StarAttraction(
      id: 'yakshagana',
      icon: Icons.theater_comedy,
      title: 'Yakshagana — Veeramani Kalaga',
      subtitle: 'Led by Yakshamitra Toronto & US artists',
      description:
          'A grand Yakshagana performance of "Veeramani Kalaga" led by Yakshamitra Toronto and US artists — one of the convention\'s most anticipated cultural evenings.',
      kannada: 'ಯಕ್ಷಗಾನ "ವೀರಮಣಿ ಕಲಾಗ"',
      iconColor: HAAColors.gold,
    ),
  ];
}

enum PhotoEventTag {
  openingCeremony('Opening Ceremony'),
  concert('Concert'),
  yakshagana('Yakshagana'),
  vedicPrograms('Vedic Programs'),
  culturalPrograms('Cultural Programs'),
  fashionShow('Fashion Show'),
  youthSymphony('Youth Symphony'),
  youthEvents('Youth Events'),
  socialHour('Social Hour'),
  meals('Meals'),
  general('General');

  const PhotoEventTag(this.label);
  final String label;

  static PhotoEventTag fromString(String value) {
    return PhotoEventTag.values.firstWhere(
      (e) => e.label == value,
      orElse: () => PhotoEventTag.general,
    );
  }

  IconData get icon {
    switch (this) {
      case PhotoEventTag.openingCeremony:
        return Icons.flag;
      case PhotoEventTag.concert:
        return Icons.mic;
      case PhotoEventTag.yakshagana:
        return Icons.theater_comedy;
      case PhotoEventTag.vedicPrograms:
        return Icons.local_fire_department;
      case PhotoEventTag.culturalPrograms:
        return Icons.theater_comedy_outlined;
      case PhotoEventTag.fashionShow:
        return Icons.checkroom;
      case PhotoEventTag.youthSymphony:
        return Icons.queue_music;
      case PhotoEventTag.youthEvents:
        return Icons.directions_run;
      case PhotoEventTag.socialHour:
        return Icons.groups;
      case PhotoEventTag.meals:
        return Icons.restaurant;
      case PhotoEventTag.general:
        return Icons.photo;
    }
  }
}

class ConventionPhoto {
  ConventionPhoto({
    required this.id,
    this.mediaURL,
    this.imageName = 'photo',
    required this.caption,
    required this.uploadedBy,
    this.uploaderEmail = '',
    required this.day,
    required this.eventTag,
    this.mediaType = PhotoMediaType.image,
    this.accentColor = HAAColors.orange,
  });

  final String id;
  final String? mediaURL;
  final String imageName;
  final String caption;
  final String uploadedBy;
  final String uploaderEmail;
  final String day;
  final PhotoEventTag eventTag;
  final PhotoMediaType mediaType;
  final Color accentColor;

  bool get isVideo => mediaType == PhotoMediaType.video;
}

enum AttendeeRole { registrant, adult, kid }

class AttendeeProfile {
  AttendeeProfile({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.role = AttendeeRole.registrant,
    this.registrationId = '',
    this.registrationUuid = '',
    this.hasCheckedIn = false,
    this.isLoggedIn = false,
  });

  String id;
  String firstName;
  String lastName;
  String email;
  AttendeeRole role;
  String registrationId;
  String registrationUuid;
  bool hasCheckedIn;
  bool isLoggedIn;

  factory AttendeeProfile.fromJson(Map<String, dynamic> json) {
    return AttendeeProfile(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: AttendeeRole.values.firstWhere(
        (r) => r.name == (json['role'] as String? ?? 'registrant'),
        orElse: () => AttendeeRole.registrant,
      ),
      registrationId: json['registrationId'] as String? ?? '',
      registrationUuid: json['uuid'] as String? ?? json['registrationUuid'] as String? ?? '',
      hasCheckedIn: json['hasCheckedIn'] as bool? ?? false,
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role.name,
        'registrationId': registrationId,
        'uuid': registrationUuid,
        'hasCheckedIn': hasCheckedIn,
        'isLoggedIn': isLoggedIn,
      };

  String? get checkInURL {
    final uuid = registrationUuid.trim();
    if (uuid.isEmpty) return null;
    return 'https://haaconvention.org/registrations-report/?t=$uuid';
  }
}

class CampusArea {
  const CampusArea({
    required this.label,
    required this.color,
    required this.description,
    this.needsBorder = false,
  });

  final String label;
  final Color color;
  final String description;
  final bool needsBorder;

  static const conventionAreas = [
    CampusArea(
      label: 'Annapoorna Bhojana Shale (Gym)',
      color: Color(0xFFE57373),
      description: 'Breakfast, lunch, and dinner.',
    ),
    CampusArea(
      label: 'Havya Paakashale (Cafeteria)',
      color: Color(0xFFE57373),
      description: 'Tea and snacks.',
    ),
    CampusArea(
      label: 'Ahichhatra Auditorium',
      color: Color(0xFF81C784),
      description: 'Main program hall for cultural programs and ceremonies.',
    ),
    CampusArea(
      label: 'Vishwamitra Kutira (Library)',
      color: Color(0xFF81C784),
      description: 'Youth activity center.',
    ),
    CampusArea(
      label: 'Havya Kavya Yaga Shale (Courtyard)',
      color: Color(0xFF81C784),
      description: 'Homa and rituals in the central courtyard.',
    ),
    CampusArea(
      label: 'Jaatre — Corridor Stalls',
      color: Color(0xFFFFB74D),
      description: 'Exhibition and artisan market along the left corridor.',
    ),
    CampusArea(
      label: 'Exhibition & Sales',
      color: Color(0xFFCE93D8),
      description: 'Angirasa Kutira (201) and Atri Kutira (203).',
    ),
    CampusArea(
      label: 'Breakout Rooms',
      color: Color(0xFFA5D6A7),
      description: 'Bharadvaja Kutira (204) and Jamadagni Kutira (206).',
    ),
    CampusArea(
      label: 'Practice Rooms',
      color: Color(0xFFC8E6C9),
      description: 'Open practice in rooms 105, 106, 107, 200, 202, and 207.',
      needsBorder: true,
    ),
    CampusArea(
      label: 'Green Rooms (Backstage)',
      color: Color(0xFF388E3C),
      description:
          'Orchestra Room (ladies), Drama Storage (mens), and Scene Storage (common).',
    ),
    CampusArea(
      label: 'Dressing Rooms',
      color: Color(0xFF90CAF9),
      description: 'Mens dressing (101, 103) and ladies dressing (102, 104).',
    ),
    CampusArea(
      label: 'Reserved Rooms',
      color: Color(0xFFFFF9C4),
      description:
          'Gautama Kutira (205) — Yakshagana; Vasishta Kutira (209) — Youth Symphony; Kashyapa Kutira (208) — supply.',
      needsBorder: true,
    ),
    CampusArea(
      label: 'Check-in Desk',
      color: Color(0xFFF48FB1),
      description: 'Convention registration at the main entrance.',
    ),
    CampusArea(
      label: 'Hallways',
      color: Color(0xFFF5F0E1),
      description: 'Walking paths connecting all venue areas.',
      needsBorder: true,
    ),
  ];
}

class ConventionData {
  static const scheduleTitle = 'HAA 21st Biennial Convention Schedule';
  static const scheduleSubtitle = 'Chicago • July 2–5, 2026';
  static const scheduleTagline = 'ನಮ್ಮ ಜನ · ನಮ್ಮತನ · ನಮ್ಮ ಧನ · ನಮ್ಮ ಋಣ';

  static final days = [
    ConventionDay(
      shortDay: 'Thu',
      fullDate: 'Thursday, July 2',
      monthDay: 'Jul 2',
      calendarDay: 2,
      events: ScheduleData2026.thursdayEvents,
    ),
    ConventionDay(
      shortDay: 'Fri',
      fullDate: 'Friday, July 3',
      monthDay: 'Jul 3',
      calendarDay: 3,
      events: ScheduleData2026.fridayEvents,
    ),
    ConventionDay(
      shortDay: 'Sat',
      fullDate: 'Saturday, July 4',
      monthDay: 'Jul 4',
      calendarDay: 4,
      events: ScheduleData2026.saturdayEvents,
    ),
    ConventionDay(
      shortDay: 'Sun',
      fullDate: 'Sunday, July 5',
      monthDay: 'Jul 5',
      calendarDay: 5,
      events: ScheduleData2026.sundayEvents,
    ),
  ];

  static final locations = [
    ConventionLocation(
      name: 'Rosary College Prep',
      subtitle: 'Convention Venue',
      address: '901 N Edgelawn Dr, Aurora, IL 60506',
      category: LocationCategory.venue,
      coordinate: LatLng(41.7753925, -88.3573770),
      detail:
          'Home of the 21st Biennial HAA Convention. All cultural programs, ceremonies, and meals take place here. Ample parking is available on campus.',
      accentColor: HAAColors.orange,
      icon: Icons.account_balance,
      distanceNote: 'Convention Venue',
    ),
    ConventionLocation(
      name: 'Hampton Inn & Suites',
      subtitle: 'from \$139/night',
      address: '2423 Bushwood Dr, Aurora, IL 60506',
      category: LocationCategory.hotels,
      coordinate: LatLng(41.7916938, -88.3765416),
      detail:
          'Negotiated HAA group rate: \$139/night (excl. taxes). Free cancellation before July 1, 2026 at 11:59 PM CDT. Located ~1.5 miles from the venue.',
      accentColor: HAAColors.gold,
      icon: Icons.hotel,
      distanceNote: '~1.5 mi from venue',
    ),
    ConventionLocation(
      name: 'Comfort Inn & Suites',
      subtitle: 'from \$110/night',
      address: '308 S Lincolnway St, North Aurora, IL 60542',
      category: LocationCategory.hotels,
      coordinate: LatLng(41.7931408, -88.3265529),
      detail:
          'Comfort Inn & Suites North Aurora–Naperville. Negotiated HAA group rate: \$110/night (excl. taxes). Free cancellation until June 24, 2026 at 4:00 PM CDT.',
      accentColor: HAAColors.gold,
      icon: Icons.hotel,
      distanceNote: '~2 mi from venue',
    ),
    ConventionLocation(
      name: 'Aurora Balaji Temple',
      subtitle: 'Sri Venkateswara Swami Temple',
      address: '1145 Sullivan Rd, Aurora, IL 60506',
      category: LocationCategory.nearby,
      coordinate: LatLng(41.7884570, -88.3498930),
      detail:
          'Hindu temple dedicated to Lord Venkateswara (Balaji), about a mile from the convention venue.',
      accentColor: const Color(0xFFB45309),
      icon: Icons.account_balance_outlined,
      distanceNote: '~1 mi from venue',
    ),
    ConventionLocation(
      name: 'Indian Vegetarian Restaurants',
      subtitle: 'Idly Vada Bistro & more',
      address: '1521 Ogden Ave, Aurora, IL 60503',
      category: LocationCategory.food,
      coordinate: LatLng(41.7206312, -88.2775297),
      detail:
          'Several South Indian and North Indian vegetarian restaurants are in the Aurora and Naperville area.',
      accentColor: const Color(0xFF1D9E75),
      icon: Icons.eco,
      distanceNote: '~4 mi from venue',
    ),
    ConventionLocation(
      name: 'Patel Brothers',
      subtitle: 'Indian Grocery',
      address: '1568 W Ogden Ave, Naperville, IL 60540',
      category: LocationCategory.food,
      coordinate: LatLng(41.7684335, -88.1843883),
      detail:
          'Patel Brothers Naperville carries Indian groceries, spices, snacks, and fresh produce.',
      accentColor: const Color(0xFF1D9E75),
      icon: Icons.shopping_cart,
      distanceNote: '~9 mi from venue',
    ),
    ConventionLocation(
      name: 'Play N Thrive Club',
      subtitle: 'Youth Activity Venue',
      address: '808 S Route 59, Ste 120, Naperville, IL 60540',
      category: LocationCategory.sports,
      coordinate: LatLng(41.7562474, -88.2023907),
      detail:
          'Youth activity on Thursday, July 2 (11:00 AM – 5:00 PM): pickleball, badminton, volleyball, and cricket nets.',
      accentColor: const Color(0xFF166E3F),
      icon: Icons.sports_tennis,
      distanceNote: 'Thu Jul 2 · 11:00 AM – 5:00 PM',
    ),
  ];
}

enum InfoAccountSection { info, account }
