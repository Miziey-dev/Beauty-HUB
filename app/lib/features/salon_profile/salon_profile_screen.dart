import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/formatting.dart';
import '../../data/discovery_repository.dart';
import '../../models/booking_draft.dart';
import '../../models/category.dart';
import '../../models/salon_profile.dart';
import '../booking/service_options_screen.dart';
import 'widgets/hero_gallery.dart';
import 'widgets/reviews_section.dart';
import 'widgets/services_section.dart';

/// Screen 4 -- Salon / Stylist profile (docs/consumer-flow.md).
class SalonProfileScreen extends StatefulWidget {
  const SalonProfileScreen({super.key, required this.salonId});

  final String salonId;

  @override
  State<SalonProfileScreen> createState() => _SalonProfileScreenState();
}

class _SalonProfileScreenState extends State<SalonProfileScreen> {
  SalonProfile? _profile;
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<DiscoveryRepository>();
    final results = await Future.wait([
      repo.fetchSalonProfile(widget.salonId),
      repo.fetchCategories(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0] as SalonProfile;
      _categories = results[1] as List<Category>;
      _loading = false;
    });
  }

  void _startBooking(SalonServiceRow service) {
    final profile = _profile!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceOptionsScreen(
          draft: BookingDraft(
            service: service,
            salonId: profile.id,
            salonName: profile.name,
            salonAddress: profile.addressLine,
            salonIsMobile: profile.isMobile,
            salonAvgResponseMinutes: profile.avgResponseMinutes,
            salonOperatingHours: profile.operatingHours,
          ),
        ),
      ),
    );
  }

  Future<void> _pickServiceThenBook() async {
    final profile = _profile!;
    final service = await showModalBottomSheet<SalonServiceRow>(
      context: context,
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        children: [
          for (final service in profile.services)
            ListTile(
              title: Text(service.styleName),
              subtitle: Text(formatRandFromCents(service.priceCents)),
              onTap: () => Navigator.of(sheetContext).pop(service),
            ),
        ],
      ),
    );
    if (service != null) _startBooking(service);
  }

  Future<void> _contactSalon(String? whatsapp) async {
    if (whatsapp == null) return;
    final uri = Uri.parse('https://wa.me/${whatsapp.replaceAll('+', '')}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final profile = _profile!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            flexibleSpace: FlexibleSpaceBar(
              background: HeroGallery(photos: profile.photos),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (profile.isVerified) const Icon(Icons.verified, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(formatRating(profile.ratingAvg, profile.ratingCount)),
                    const SizedBox(height: 4),
                    Text(
                      profile.isMobile
                          ? 'Mobile -- comes to you'
                          : (profile.addressLine ?? profile.suburb),
                    ),
                    if (profile.avgResponseMinutes != null) ...[
                      const SizedBox(height: 4),
                      Text('Responds in ~${profile.avgResponseMinutes}min'),
                    ],
                    if (!profile.isClaimed) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 8),
                            Expanded(child: Text('Info from public listings -- own this salon? Claim it')),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              ServicesSection(
                servicesByCategory: profile.servicesByCategory,
                categories: _categories,
                onBook: _startBooking,
              ),
              const Divider(height: 1),
              ReviewsSection(
                reviews: profile.reviews,
                ratingAvg: profile.ratingAvg,
                ratingCount: profile.ratingCount,
              ),
              const SizedBox(height: 96),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: profile.isClaimed
              ? FilledButton(
                  onPressed: _pickServiceThenBook,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Book now'),
                )
              : OutlinedButton.icon(
                  onPressed: () => _contactSalon(profile.whatsapp),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Contact via WhatsApp'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
        ),
      ),
    );
  }
}
