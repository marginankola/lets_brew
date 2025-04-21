import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUtils {
  // Show a snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Format a DateTime
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'MMM d, yyyy',
  }) {
    final DateFormat formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  // Get a friendly time ago string
  static String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Save a value to SharedPreferences
  static Future<bool> saveToPrefs(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    }

    return false;
  }

  // Get a value from SharedPreferences
  static Future<dynamic> getFromPrefs(
    String key, {
    dynamic defaultValue,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(key)) {
      return defaultValue;
    }

    return prefs.get(key);
  }

  // Remove a value from SharedPreferences
  static Future<bool> removeFromPrefs(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  // Check if device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Convert seconds to a formatted time string (mm:ss)
  static String formatSeconds(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  // Convert hex color string to Color
  static Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Generate a random color
  static Color getRandomColor({int opacity = 255}) {
    return Color.fromARGB(
      opacity,
      (DateTime.now().millisecondsSinceEpoch % 255),
      (DateTime.now().microsecondsSinceEpoch % 255),
      (DateTime.now().millisecondsSinceEpoch * 13 % 255),
    );
  }
}
