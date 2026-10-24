import '../constants/app_constants.dart';

/// Builds the time-of-day greeting for Anis.
class Greeting {
  Greeting._();

  static String forHour(int hour, {String name = AppConstants.partnerName}) {
    final String part;
    if (hour < 5) {
      part = 'Still up';
    } else if (hour < 12) {
      part = 'Good morning';
    } else if (hour < 17) {
      part = 'Good afternoon';
    } else if (hour < 22) {
      part = 'Good evening';
    } else {
      part = 'Goodnight soon';
    }
    return '$part, $name 💗';
  }

  static String now({String name = AppConstants.partnerName}) =>
      forHour(DateTime.now().hour, name: name);
}
