import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/booking_draft.dart';
import '../auth/phone_auth_screen.dart';
import 'deposit_confirm_screen.dart';
import 'time_slot_generator.dart';

/// Screen 5b -- Date & time, with the auth gate before continuing
/// (docs/consumer-flow.md): "slots are requests, not confirmed bookings."
class DateTimeScreen extends StatefulWidget {
  const DateTimeScreen({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedSlot;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.draft.date ?? DateTime.now();
  }

  List<TimeOfDay> get _slots => generateTimeSlots(
        operatingHours: widget.draft.salonOperatingHours,
        date: _selectedDate,
        serviceDurationMinutes: widget.draft.service.durationMinutes,
      );

  Future<void> _continue() async {
    if (_selectedSlot == null) return;
    setState(() => _busy = true);
    final signedIn = await ensureSignedIn(context);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!signedIn) return;

    final draft = widget.draft.copyWith(date: _selectedDate, timeSlot: _selectedSlot);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DepositConfirmScreen(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final next30Days = List.generate(30, (i) => DateTime(today.year, today.month, today.day + i));
    final responseMinutes = widget.draft.salonAvgResponseMinutes;
    final confirmCopy = responseMinutes != null
        ? Strings.confirmsWithinMinutes(widget.draft.salonName, responseMinutes)
        : Strings.confirmsWithinDefault(widget.draft.salonName);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.dateAndTime)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: next30Days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = next30Days[index];
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                return ChoiceChip(
                  label: Text('${date.day}/${date.month}'),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _selectedDate = date;
                    _selectedSlot = null;
                  }),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _slots.isEmpty
                ? const Center(child: Text(Strings.closedThisDay))
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final slot in _slots)
                          ChoiceChip(
                            label: Text(slot.format(context)),
                            selected: _selectedSlot == slot,
                            onSelected: (_) => setState(() => _selectedSlot = slot),
                          ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(confirmCopy, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _selectedSlot != null && !_busy ? _continue : null,
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text(Strings.continueLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
