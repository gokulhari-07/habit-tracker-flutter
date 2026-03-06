class StreakService {
  static int calculateCurrentStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    // Normalize all dates to midnight (remove time component)
    final dates = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending — most recent first

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterday = todayNormalized.subtract(const Duration(days: 1));

    // Streak must start from today or yesterday
    if (dates.first != todayNormalized && dates.first != yesterday) return 0;

    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int calculateLongestStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final dates = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Sort ascending

    int longest = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}