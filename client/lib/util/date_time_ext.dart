extension Date on DateTime {
  DateTime toLocalMidnight() => DateTime(year, month, day);

  String weekdayString() {
    switch (weekday) {
      case (DateTime.sunday):
        return 'Sunday';
      case (DateTime.monday):
        return 'Monday';
      case (DateTime.tuesday):
        return 'Tuesday';
      case (DateTime.wednesday):
        return 'Wednesday';
      case (DateTime.thursday):
        return 'Thursday';
      case (DateTime.friday):
        return 'Friday';
      case (DateTime.saturday):
        return 'Saturday';
      default:
        throw ArgumentError(this);
    }
  }

  String weekdayAbbrevString() {
    switch (weekday) {
      case (DateTime.sunday):
        return 'Sun';
      case (DateTime.monday):
        return 'Mon';
      case (DateTime.tuesday):
        return 'Tue';
      case (DateTime.wednesday):
        return 'Wed';
      case (DateTime.thursday):
        return 'Thu';
      case (DateTime.friday):
        return 'Fri';
      case (DateTime.saturday):
        return 'Sat';
      default:
        throw ArgumentError(this);
    }
  }

  /// Add days, accounting for daylight savings change
  DateTime addDays(int deltaDays) {
    return DateTime(year, month, day + deltaDays, hour, minute, second, millisecond, microsecond);
  }

  /// Subtract days, accounting for daylight savings change
  DateTime subtractDays(int deltaDays) => addDays(-deltaDays);
}
