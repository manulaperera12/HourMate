import 'dart:math';
import '../../features/home/domain/entities/work_entry.dart';

class ProductivityCalculator {
  static const Map<String, int> _ratingScores = {
    'good': 100,
    'average': 70,
    'bad': 40,
  };

  static double _getRatingScore(String rating) {
    return (_ratingScores[rating.toLowerCase()] ?? 70).toDouble();
  }

  /// Multi-Factor Productivity Index
  /// Combines quality, efficiency, consistency, and focus
  static double calculateMultiFactorProductivity(
    List<WorkEntry> entries,
    double dailyGoal,
  ) {
    if (entries.isEmpty) return 0.0;

    // Quality Score (40%) - Task ratings
    final qualityScore =
        entries
            .map((e) => _getRatingScore(e.taskRating))
            .reduce((a, b) => a + b) /
        entries.length;

    // Efficiency Score (30%) - Hours vs goals
    final totalHours = entries.fold<double>(
      0.0,
      (sum, e) => sum + e.durationInHours,
    );
    final efficiencyScore = (totalHours / dailyGoal).clamp(0.0, 1.5) * 100;

    // Consistency Score (20%) - Rating consistency
    final consistencyScore = _calculateConsistencyScore(entries);

    // Focus Score (10%) - Optimal session length
    final focusScore = _calculateFocusScore(entries);

    return (qualityScore * 0.4 +
            efficiencyScore * 0.3 +
            consistencyScore * 0.2 +
            focusScore * 0.1)
        .clamp(0.0, 100.0);
  }

  /// Time-Weighted Productivity
  /// Weights ratings by session duration
  static double calculateTimeWeightedProductivity(List<WorkEntry> entries) {
    if (entries.isEmpty) return 0.0;

    double totalWeightedScore = 0.0;
    double totalHours = 0.0;

    for (final entry in entries) {
      final hours = entry.durationInHours;
      final ratingScore = _getRatingScore(entry.taskRating);

      totalWeightedScore += (ratingScore * hours);
      totalHours += hours;
    }

    return totalHours > 0 ? (totalWeightedScore / totalHours) : 0.0;
  }

  /// Consistency-Based Productivity
  /// Rewards consistent performance
  static double calculateConsistencyProductivity(List<WorkEntry> entries) {
    if (entries.length < 2) return 70.0;

    final ratings = entries.map((e) => _getRatingScore(e.taskRating)).toList();
    final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

    // Calculate standard deviation
    final variance =
        ratings.map((r) => pow(r - averageRating, 2)).reduce((a, b) => a + b) /
        ratings.length;
    final stdDev = sqrt(variance);

    // Higher consistency (lower std dev) = higher productivity
    final consistencyBonus = (100 - stdDev).clamp(0.0, 30.0);

    return (averageRating + consistencyBonus).clamp(0.0, 100.0);
  }

  /// Peak Hours Productivity
  /// Identifies and rewards peak performance hours
  static double calculatePeakHoursProductivity(List<WorkEntry> entries) {
    if (entries.isEmpty) return 0.0;

    // Group by hour and find peak productivity hours
    final Map<int, List<double>> hourlyRatings = {};

    for (final entry in entries) {
      final hour = entry.startTime.hour;
      final rating = _getRatingScore(entry.taskRating);

      hourlyRatings.putIfAbsent(hour, () => []).add(rating);
    }

    // Calculate average rating for each hour
    final hourlyAverages = hourlyRatings.map((hour, ratings) {
      return MapEntry(hour, ratings.reduce((a, b) => a + b) / ratings.length);
    });

    // Find peak hours (top 3 hours)
    final sortedHours = hourlyAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final peakHours = sortedHours.take(3);
    final peakAverage =
        peakHours.fold<double>(0.0, (sum, e) => sum + e.value) /
        peakHours.length.toDouble();

    return peakAverage;
  }

  /// Trend-Based Productivity
  /// Rewards improving performance over time
  static double calculateTrendProductivity(List<WorkEntry> entries) {
    if (entries.length < 3) return 70.0;

    // Sort by date and calculate moving average
    final sortedEntries = entries.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final ratings = sortedEntries
        .map((e) => _getRatingScore(e.taskRating))
        .toList();

    // Calculate trend (positive trend = bonus, negative trend = penalty)
    double trendBonus = 0.0;
    if (ratings.length >= 3) {
      final recentAvg =
          ratings.skip(ratings.length - 3).reduce((a, b) => a + b) / 3;
      final earlierAvg = ratings.take(3).reduce((a, b) => a + b) / 3;
      final trend = recentAvg - earlierAvg;
      trendBonus = trend.clamp(-10.0, 10.0);
    }

    final baseScore = ratings.reduce((a, b) => a + b) / ratings.length;
    return (baseScore + trendBonus).clamp(0.0, 100.0);
  }

  /// Context-Aware Productivity
  /// Adjusts for time of day and day of week
  static double calculateContextAwareProductivity(List<WorkEntry> entries) {
    if (entries.isEmpty) return 0.0;

    final now = DateTime.now();
    final isWeekend = now.weekday > 5;
    final isEvening = now.hour >= 18 || now.hour <= 6;

    double contextMultiplier = 1.0;

    // Adjust for context
    if (isWeekend) contextMultiplier = 1.2; // Weekend work gets bonus
    if (isEvening) contextMultiplier = 1.1; // Evening work gets bonus

    final baseScore =
        entries
            .map((e) => _getRatingScore(e.taskRating))
            .reduce((a, b) => a + b) /
        entries.length;

    return (baseScore * contextMultiplier).clamp(0.0, 100.0);
  }

  // Helper methods
  static double _calculateConsistencyScore(List<WorkEntry> entries) {
    if (entries.length < 2) return 70.0;

    final ratings = entries.map((e) => _getRatingScore(e.taskRating)).toList();
    final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

    final variance =
        ratings.map((r) => pow(r - averageRating, 2)).reduce((a, b) => a + b) /
        ratings.length;
    final stdDev = sqrt(variance);

    final consistencyBonus = (100 - stdDev).clamp(0.0, 30.0);
    return (averageRating + consistencyBonus).clamp(0.0, 100.0);
  }

  static double _calculateFocusScore(List<WorkEntry> entries) {
    if (entries.isEmpty) return 0.0;

    return entries
            .map((entry) {
              final minutes = entry.durationInMinutes;
              if (minutes >= 25 && minutes <= 90) return 100.0; // Optimal range
              if (minutes >= 15 && minutes <= 120) return 80.0; // Good range
              return 60.0; // Too short or too long
            })
            .reduce((a, b) => a + b) /
        entries.length;
  }

  /// Get productivity insights for display
  static Map<String, dynamic> getProductivityInsights(
    List<WorkEntry> entries,
    double dailyGoal,
  ) {
    if (entries.isEmpty) {
      return {
        'score': 0.0,
        'type': 'No data',
        'insights': ['No work sessions recorded today'],
      };
    }

    final multiFactorScore = calculateMultiFactorProductivity(
      entries,
      dailyGoal,
    );
    final consistencyScore = calculateConsistencyProductivity(entries);
    final peakHoursScore = calculatePeakHoursProductivity(entries);
    final trendScore = calculateTrendProductivity(entries);

    final insights = <String>[];

    // Quality insights
    final avgRating =
        entries
            .map((e) => _getRatingScore(e.taskRating))
            .reduce((a, b) => a + b) /
        entries.length;
    if (avgRating >= 90) {
      insights.add('Excellent task quality today!');
    } else if (avgRating >= 80) {
      insights.add('Good task quality maintained');
    } else if (avgRating < 60) {
      insights.add('Consider reviewing task approach');
    }

    // Efficiency insights
    final totalHours = entries.fold<double>(
      0.0,
      (sum, e) => sum + e.durationInHours,
    );
    final efficiencyRatio = totalHours / dailyGoal;
    if (efficiencyRatio >= 1.2) {
      insights.add(
        'Exceeded daily goal by ${((efficiencyRatio - 1) * 100).round()}%',
      );
    } else if (efficiencyRatio < 0.8) {
      insights.add(
        '${((1 - efficiencyRatio) * 100).round()}% below daily goal',
      );
    }

    // Consistency insights
    if (consistencyScore > 85) {
      insights.add('Very consistent performance');
    } else if (consistencyScore < 70) {
      insights.add('Performance varies significantly');
    }

    // Focus insights
    final focusScore = _calculateFocusScore(entries);
    if (focusScore >= 90) {
      insights.add('Optimal session lengths');
    } else if (focusScore < 70) {
      insights.add('Consider adjusting session duration');
    }

    String productivityType;
    if (multiFactorScore >= 90) {
      productivityType = 'Exceptional';
    } else if (multiFactorScore >= 80) {
      productivityType = 'Excellent';
    } else if (multiFactorScore >= 70) {
      productivityType = 'Good';
    } else if (multiFactorScore >= 60) {
      productivityType = 'Average';
    } else {
      productivityType = 'Needs Improvement';
    }

    return {
      'score': multiFactorScore.round(),
      'type': productivityType,
      'insights': insights,
      'breakdown': {
        'quality': avgRating.round(),
        'efficiency': (efficiencyRatio * 100).clamp(0.0, 150.0).round(),
        'consistency': consistencyScore.round(),
        'focus': focusScore.round(),
      },
    };
  }
}
