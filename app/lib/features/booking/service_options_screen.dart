import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../models/booking_draft.dart';
import 'date_time_screen.dart';

/// Screen 5a -- Service & options (docs/consumer-flow.md).
class ServiceOptionsScreen extends StatefulWidget {
  const ServiceOptionsScreen({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<ServiceOptionsScreen> createState() => _ServiceOptionsScreenState();
}

class _ServiceOptionsScreenState extends State<ServiceOptionsScreen> {
  late BookingDraft _draft;
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  bool get _canOfferHairAddOn => !_draft.service.hairIncluded && _draft.service.hairIncludedPriceDeltaCents > 0;

  bool get _canContinue => !_draft.isAtCustomer || _addressController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service & options')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_draft.service.styleName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${formatRandFromCents(_draft.service.priceCents)} · ${formatDuration(_draft.service.durationMinutes)}',
          ),
          if (_draft.service.hairIncluded) ...[
            const SizedBox(height: 4),
            const Text('Hair included in this price'),
          ],
          if (_canOfferHairAddOn) ...[
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Add hair'),
              subtitle: Text('+${formatRandFromCents(_draft.service.hairIncludedPriceDeltaCents)} -- otherwise bring your own'),
              value: _draft.addHair,
              onChanged: (value) => setState(() => _draft = _draft.copyWith(addHair: value)),
            ),
          ],
          if (_draft.salonIsMobile) ...[
            const Divider(height: 32),
            const Text('Where should the stylist come to?', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _draft.locationType,
              onChanged: (value) => setState(() => _draft = _draft.copyWith(locationType: value)),
              child: Column(
                children: [
                  const RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('At salon'),
                    value: 'at_salon',
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('At my place (+${formatRandFromCents(flatTravelFeeCents)} travel fee)'),
                    value: 'at_customer',
                  ),
                ],
              ),
            ),
            if (_draft.isAtCustomer)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Your address', border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _draft = _draft.copyWith(customerAddress: value)),
                ),
              ),
          ],
          const Divider(height: 32),
          Text('Total: ${formatRandFromCents(_draft.totalPriceCents)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _canContinue
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DateTimeScreen(draft: _draft)),
                    )
                : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
