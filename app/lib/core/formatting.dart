/// Cents are stored as integers everywhere (see supabase/migrations); these
/// helpers are the one place that turns them into display strings.
String formatRandFromCents(int cents) => 'R${(cents / 100).round()}';

String formatDistanceKm(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

String formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) return '${mins}min';
  if (mins == 0) return '±${hours}hr';
  return '±${hours}hr ${mins}min';
}

String formatRating(num rating, int count) => '★ ${rating.toStringAsFixed(1)} ($count)';

String formatRatingBadge(num rating) => '★ ${rating.toStringAsFixed(1)}';
