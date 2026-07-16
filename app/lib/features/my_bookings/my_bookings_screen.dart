import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/formatting.dart';
import '../../data/booking_repository.dart';
import '../../l10n/strings.dart';
import '../../models/my_booking.dart';
import '../review/leave_review_screen.dart';
import '../salon_profile/salon_profile_screen.dart';
import 'widgets/similar_stylists_row.dart';

/// Screen 6 -- My Bookings (docs/consumer-flow.md).
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<MyBooking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final bookings = await context.read<BookingRepository>().fetchMyBookings();
    if (!mounted) return;
    setState(() {
      _bookings = bookings;
      _loading = false;
    });
  }

  Future<void> _cancel(MyBooking booking) async {
    final now = DateTime.now();
    final freeCancel = booking.isCancellableFreely(now);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(Strings.cancelThisBookingTitle),
        content: Text(
          freeCancel ? Strings.freeCancellationNotice : Strings.forfeitCancellationNotice,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text(Strings.keepBooking)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text(Strings.cancelBooking)),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await context.read<BookingRepository>().cancelBooking(booking.id);
    await _load();
  }

  Future<void> _getDirections(MyBooking booking) async {
    final query = Uri.encodeComponent(booking.salonAddress ?? booking.salonName);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _bookings.where((b) => b.isUpcoming).toList();
    final past = _bookings.where((b) => !b.isUpcoming).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.myBookings),
          bottom: const TabBar(tabs: [Tab(text: Strings.upcomingTab), Tab(text: Strings.pastTab)]),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: TabBarView(
                  children: [
                    _BookingList(
                      bookings: upcoming,
                      emptyMessage: Strings.noUpcomingBookings,
                      builder: (booking) => _UpcomingCard(
                        booking: booking,
                        onCancel: () => _cancel(booking),
                        onDirections: () => _getDirections(booking),
                      ),
                    ),
                    _BookingList(
                      bookings: past,
                      emptyMessage: Strings.noPastBookings,
                      builder: (booking) => _PastCard(booking: booking, onReviewed: _load),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings, required this.emptyMessage, required this.builder});

  final List<MyBooking> bookings;
  final String emptyMessage;
  final Widget Function(MyBooking) builder;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(emptyMessage)))]);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => builder(bookings[index]),
    );
  }
}

Color _statusColor(BuildContext context, String status) => switch (status) {
      'confirmed' => Colors.green,
      'declined' => Theme.of(context).colorScheme.error,
      'cancelled' => Colors.grey,
      _ => Colors.orange,
    };

String _statusLabel(String status) => switch (status) {
      'pending' => Strings.statusAwaitingConfirmation,
      'confirmed' => Strings.statusConfirmed,
      'declined' => Strings.statusDeclined,
      'cancelled' => Strings.statusCancelled,
      'completed' => Strings.statusCompleted,
      _ => status,
    };

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.booking, required this.onCancel, required this.onDirections});

  final MyBooking booking;
  final VoidCallback onCancel;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(_statusLabel(booking.status), style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: _statusColor(context, booking.status),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                Text(formatRandFromCents(booking.depositAmountCents)),
              ],
            ),
            const SizedBox(height: 8),
            Text(booking.styleName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(booking.salonName),
            Text('${booking.requestedDate.day}/${booking.requestedDate.month}/${booking.requestedDate.year} at ${booking.requestedTimeSlot.substring(0, 5)}'),
            const SizedBox(height: 8),
            if (booking.status == 'pending' || booking.status == 'confirmed')
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(onPressed: onDirections, child: const Text(Strings.getDirections)),
                  OutlinedButton(onPressed: onCancel, child: const Text(Strings.cancel)),
                ],
              ),
            if (booking.status == 'declined' || booking.status == 'cancelled') ...[
              const Divider(height: 24),
              const Text(Strings.youMightAlsoLike, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SimilarStylistsRow(styleId: booking.styleId, excludeSalonId: booking.salonId),
            ],
          ],
        ),
      ),
    );
  }
}

class _PastCard extends StatelessWidget {
  const _PastCard({required this.booking, required this.onReviewed});

  final MyBooking booking;
  final VoidCallback onReviewed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.styleName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(booking.salonName),
            Text('${booking.requestedDate.day}/${booking.requestedDate.month}/${booking.requestedDate.year}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SalonProfileScreen(salonId: booking.salonId)),
                  ),
                  child: const Text(Strings.bookAgain),
                ),
                if (booking.status == 'completed')
                  booking.hasReview
                      ? const Chip(label: Text(Strings.reviewed))
                      : FilledButton(
                          onPressed: () async {
                            final submitted = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => LeaveReviewScreen(bookingId: booking.id, salonId: booking.salonId),
                              ),
                            );
                            if (submitted == true) onReviewed();
                          },
                          child: const Text(Strings.leaveAReview),
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
