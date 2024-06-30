import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:intl/intl.dart';

class TimezoneHelper {
  Map<String, List<String>> countryTimezones = {};
  Map<String, String> timezoneToCountry = {};

  Future<void> loadTimezones() async {
    try {
      final String response = await rootBundle.loadString('assets/country_timezones.json');
      final Map<String, dynamic> data = json.decode(response);

      if (data is Map<String, dynamic>) {
        data.forEach((country, timezonesData) {
          if (timezonesData is List<dynamic>) {
            List<String> timezones = timezonesData.cast<String>(); // Cast List<dynamic> to List<String>
            countryTimezones[country] = timezones;
          }
        });
      }

      tzData.initializeTimeZones();

      // Create a map from timezone to country
      countryTimezones.forEach((country, timezones) {
        timezones.forEach((timezone) {
          timezoneToCountry[timezone] = country;
        });
      });
    } catch (e) {
      print('Error loading timezones: $e');
    }
  }

  String getCurrentTime(String timeZoneId) {
    try {
      tz.Location location = tz.getLocation(timeZoneId);
      DateTime now = tz.TZDateTime.now(location);
      return DateFormat.Hms().format(now); // Returns only time in HH:mm:ss format
    } catch (e) {
      print('Error getting current time for timezone $timeZoneId: $e');
      return 'Unknown Time';
    }
  }

  String getCurrentDate(String timeZoneId) {
    try {
      tz.Location location = tz.getLocation(timeZoneId);
      DateTime now = tz.TZDateTime.now(location);
      return DateFormat.yMMMd().format(now); // Returns date in MMM d, y format
    } catch (e) {
      print('Error getting current date for timezone $timeZoneId: $e');
      return 'Unknown Date';
    }
  }

  String getTimeZoneAbbreviation(String timeZoneId) {
    try {
      tz.Location location = tz.getLocation(timeZoneId);
      DateTime now = tz.TZDateTime.now(location);
      return now.timeZoneOffset.isNegative ? 'UTC-${now.timeZoneOffset.inHours.abs()}' : 'UTC+${now.timeZoneOffset.inHours}';
    } catch (e) {
      print('Error getting timezone abbreviation for timezone $timeZoneId: $e');
      return '';
    }
  }

  String getTimeZoneId(String countryCode) {
    List<String> timezones = countryTimezones[countryCode] ?? ['UTC'];
    return timezones.first;
  }

  Future<String?> getCountryCodeFromPhoneNumber(String phoneNumber) async {
    try {
      PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
      return number.isoCode;
    } catch (e) {
      print("Error parsing phone number: $e");
      return null;
    }
  }
}
