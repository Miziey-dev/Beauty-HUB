import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatting.dart';
import '../../data/auth_data_source.dart';
import '../../data/booking_repository.dart';
import '../../data/payment_gateway.dart';
import '../../models/booking_draft.dart';
import 'booking_success_screen.dart';

/// Screen 5c -- Deposit & confirm (docs/consumer-flow.md).
class DepositConfirmScreen extends StatefulWidget {
  const DepositConfirmScreen({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<DepositConfirmScreen> createState() => _DepositConfirmScreenState();
}

class _DepositConfirmScreenState extends State<DepositConfirmScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _payAndConfirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final draft = widget.draft;
      final result = await context.read<PaymentGateway>().chargeDeposit(
            amountCents: draft.depositAmountCents,
            bookingReference: '${draft.salonId}-${DateTime.now().millisecondsSinceEpoch}',
          );
      if (!result.success) {
        setState(() => _error = result.errorMessage ?? 'Payment failed -- please try again');
        return;
      }
      if (!mounted) return;

      final customerId = context.read<AuthDataSource>().currentUserId;
      final booking = await context.read<BookingRepository>().createBooking(
            draft: draft,
            customerId: customerId!,
            paystackReference: result.reference,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BookingSuccessScreen(booking: booking)),
      );
    } catch (e) {
      setState(() => _error = 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final date = draft.date!;
    final time = draft.timeSlot!;

    return Scaffold(
      appBar: AppBar(title: const Text('Deposit & confirm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(draft.service.styleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(draft.salonName),
                  const SizedBox(height: 4),
                  Text('${date.day}/${date.month}/${date.year} at ${time.format(context)}'),
                  const SizedBox(height: 4),
                  Text(draft.isAtCustomer ? (draft.customerAddress ?? 'Your address') : (draft.salonAddress ?? draft.salonName)),
                  const Divider(height: 24),
                  _PriceRow(label: 'Service', amountCents: draft.service.priceCents),
                  if (draft.hairAdjustmentCents > 0) _PriceRow(label: 'Hair', amountCents: draft.hairAdjustmentCents),
                  if (draft.travelFeeCents > 0) _PriceRow(label: 'Travel fee', amountCents: draft.travelFeeCents),
                  const Divider(height: 24),
                  _PriceRow(label: 'Deposit due now', amountCents: draft.depositAmountCents, bold: true),
                  _PriceRow(label: 'Balance due at appointment', amountCents: draft.balanceDueCents),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Free cancellation until 48 hrs before; after that the deposit is forfeited.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _busy ? null : _payAndConfirm,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Pay ${formatRandFromCents(draft.depositAmountCents)} deposit'),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.amountCents, this.bold = false});

  final String label;
  final int amountCents;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatRandFromCents(amountCents), style: style),
        ],
      ),
    );
  }
}
