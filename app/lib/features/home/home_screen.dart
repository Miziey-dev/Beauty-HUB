import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../data/discovery_repository.dart';
import '../../location/location_controller.dart';
import '../../models/category.dart';
import '../../models/salon_search_result.dart';
import '../../models/style_feed_item.dart';
import '../salon_profile/salon_profile_screen.dart';
import '../style_results/style_results_screen.dart';
import 'widgets/category_chip_row.dart';
import 'widgets/style_card.dart';

/// Screen 2 -- Home / Style Feed, the heart of the app
/// (docs/consumer-flow.md).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  String? _selectedCategory;
  List<StyleFeedItem> _items = [];
  bool _widenedRadius = false;
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = context.read<DiscoveryRepository>();
    final location = context.read<LocationController>();

    final categories = _categories.isEmpty ? await repo.fetchCategories() : _categories;
    final result = await repo.fetchStyleFeed(
      lat: location.lat!,
      lng: location.lng!,
      categorySlug: _selectedCategory,
    );

    if (!mounted) return;
    setState(() {
      _categories = categories;
      _items = result.items;
      _widenedRadius = result.widenedRadius;
      _loading = false;
    });
  }

  List<StyleFeedItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) => item.styleName.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.location_on_outlined),
          label: Text(location.label),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: _StyleSearchDelegate(this)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: CategoryChipRow(
                        categories: _categories,
                        selected: _selectedCategory,
                        onSelected: (slug) {
                          setState(() => _selectedCategory = slug);
                          _load();
                        },
                      ),
                    ),
                  ),
                  if (_widenedRadius)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text('Showing results a bit further out'),
                      ),
                    ),
                  if (_filteredItems.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('No styles nearby yet -- check back soon')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return StyleCard(
                            item: item,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StyleResultsScreen(
                                  styleId: item.styleId,
                                  styleName: item.styleName,
                                  coverPhotoUrl: item.coverPhotoUrl,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _StyleSearchDelegate extends SearchDelegate<void> {
  _StyleSearchDelegate(this.homeState);

  final _HomeScreenState homeState;

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    final styleMatches = homeState._items
        .where((item) => item.styleName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final repo = homeState.context.read<DiscoveryRepository>();

    return FutureBuilder<List<SalonSearchResult>>(
      future: repo.searchSalonsByName(query),
      builder: (context, snapshot) {
        final salonMatches = snapshot.data ?? [];
        return ListView(
          children: [
            for (final item in styleMatches)
              ListTile(
                leading: const Icon(Icons.brush_outlined),
                title: Text(item.styleName),
                onTap: () {
                  close(context, null);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StyleResultsScreen(
                        styleId: item.styleId,
                        styleName: item.styleName,
                        coverPhotoUrl: item.coverPhotoUrl,
                      ),
                    ),
                  );
                },
              ),
            for (final salon in salonMatches)
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(salon.name),
                onTap: () {
                  close(context, null);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SalonProfileScreen(salonId: salon.id),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
