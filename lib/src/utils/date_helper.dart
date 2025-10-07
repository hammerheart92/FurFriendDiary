import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

/// Returns a localized relative date label (e.g., "Today", "Tomorrow", "Friday", or a formatted date).
/// 
/// The function normalizes dates to local midnight to ensure correct day calculation,
/// regardless of the time portion of the DateTime.
String relativeDateLabel(BuildContext context, DateTime dateTime) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();

  final now = DateTime.now().toLocal();
  final target = dateTime.toLocal();

  // Normalize both dates to midnight for accurate day comparison
  final today = DateTime(now.year, now.month, now.day);
  final targetDateOnly = DateTime(target.year, target.month, target.day);
  
  // Calculate difference in days
  final diff = targetDateOnly.difference(today).inDays;

  if (diff == 0) {
    return l10n.today; // "Today" / "Astăzi"
  } else if (diff == 1) {
    return l10n.tomorrow; // "Tomorrow" / "Mâine"
  } else if (diff > 1 && diff < 7) {
    // Weekday name, localized (e.g., "Friday" / "vineri")
    return DateFormat.EEEE(locale).format(target);
  } else if (diff >= 7) {
    // Full short date, localized (e.g., "Oct 15, 2025" / "15 oct. 2025")
    return DateFormat.yMMMd(locale).format(target);
  } else if (diff == -1) {
    return l10n.yesterday; // "Yesterday" / "Ieri"
  } else {
    // Past date beyond yesterday
    return DateFormat.yMMMd(locale).format(target);
  }
}

/// Returns a localized time string (e.g., "9:00 PM" for English, "21:00" for Romanian).
String localizedTime(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.jm(locale).format(dateTime.toLocal());
}

/// Returns a localized date string in short format (e.g., "Oct 15" / "15 oct.").
String localizedShortDate(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.MMMd(locale).format(dateTime.toLocal());
}

/// Returns a localized full date string (e.g., "October 15, 2025" / "15 octombrie 2025").
String localizedFullDate(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMMd(locale).format(dateTime.toLocal());
}

/// Returns the number of days until/since a given date.
/// Positive values indicate future dates, negative values indicate past dates.
int daysUntil(DateTime dateTime) {
  final now = DateTime.now().toLocal();
  final target = dateTime.toLocal();
  
  final today = DateTime(now.year, now.month, now.day);
  final targetDateOnly = DateTime(target.year, target.month, target.day);
  
  return targetDateOnly.difference(today).inDays;
}

/// Returns a human-readable "time ago" string (e.g., "2 hours ago", "Just now").
String timeAgo(BuildContext context, DateTime dateTime) {
  final l10n = AppLocalizations.of(context);
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 0) {
    return l10n.daysAgo(difference.inDays);
  } else if (difference.inHours > 0) {
    return l10n.hoursAgo(difference.inHours);
  } else if (difference.inMinutes > 0) {
    return l10n.minutesAgo(difference.inMinutes);
  } else {
    return l10n.justNow;
  }
}

