class RateCache {
  final double rate;
  final DateTime timestamp;

  const RateCache({
    required this.rate,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateCache &&
          runtimeType == other.runtimeType &&
          rate == other.rate &&
          timestamp == other.timestamp;

  @override
  int get hashCode => rate.hashCode ^ timestamp.hashCode;
}
