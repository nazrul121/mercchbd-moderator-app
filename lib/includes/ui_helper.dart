import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class UIHelper {
  static Widget bottomBorderSpace({double height = 12.0}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1.0),
        ),
      ),
    );
  }
}

String formatMyDate(String rawDate) {
  try {
    // Parse the string (e.g., "2025-11-11") into a DateTime object
    DateTime parsedDate = DateTime.parse(rawDate);
    // Format it (e.g., "11 Nov, 2025")
    return DateFormat('dd MMM, yyyy').format(parsedDate);
  } catch (e) {
    return rawDate; // Fallback to raw string if parsing fails
  }
}

String formatTargetMonth(dynamic rawMonth) {
  // Convert whatever we got (int, String, etc) into a String
  String dateStr = rawMonth?.toString() ?? '';

  if (dateStr.isEmpty) return 'N/A';

  try {
    // If the API gives 202511 (int) or "2025-11" (String)
    // We ensure it looks like "2025-11-01"
    String dateToParse = dateStr.contains('-') && dateStr.length == 7
        ? "$dateStr-01"
        : dateStr;

    DateTime parsedDate = DateTime.parse(dateToParse);
    return DateFormat('MMMM yyyy').format(parsedDate);
  } catch (e) {
    return dateStr;
  }
}