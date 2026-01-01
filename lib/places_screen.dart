import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'destination_detail_page.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({Key? key}) : super(key: key);

  static const _brandBlue = Color(0xFF5179BA);
  static const _buttonBlue = Color(0xFF2B60B6);
  static const _orange = Color(0xFFF36D3A);
  static const _red = Color(0xFFF64F59);
  static const _bg = Color(0xFFF7F7F7);
  static const _dark = Color(0xFF1F1F1F);
  static const _muted = Color(0xFF6A6A6A);
  static const _cardBorder = Color(0xFFE8E8E8);
  static const _placeholderColor = Color(0xFFE5E7EB);

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const int _pageSize = 10;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  List<String> _categories = const ['All'];
  String _selectedCategory = 'All';

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _refresh();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _handleScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('destinations')
          .limit(50)
          .get();
      final set = <String>{'All'};
      for (final d in snap.docs) {
        final c = d.data()['category'];
        if (c is String && c.trim().isNotEmpty) set.add(c.trim());
      }
      setState(() => _categories = set.toList()..sort());
    } catch (_) {
      // Keep default list on error.
    }
  }

  Query<Map<String, dynamic>> _buildQuery() {
    final search = _searchController.text.trim();
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance.collection(
      'destinations',
    );

    if (_selectedCategory != 'All') {
      q = q.where('category', isEqualTo: _selectedCategory);
    }

    if (search.isNotEmpty) {
      q = q
          .orderBy(FieldPath.documentId)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: search)
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$search\uf8ff');
    } else {
      q = q.orderBy('rating', descending: true);
    }

    return q;
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _lastDoc = null;
      _docs.clear();
    });

    try {
      final snap = await _buildQuery().limit(_pageSize).get();
      setState(() {
        _docs.addAll(snap.docs);
        _lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
        _hasMore = snap.docs.length == _pageSize;
      });
    } on FirebaseException catch (e) {
      _showError(e.message ?? 'Failed to load destinations.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    try {
      var q = _buildQuery().limit(_pageSize);
      if (_lastDoc != null) q = q.startAfterDocument(_lastDoc!);

      final snap = await q.get();
      if (snap.docs.isNotEmpty) {
        setState(() {
          _docs.addAll(snap.docs);
          _lastDoc = snap.docs.last;
          _hasMore = snap.docs.length == _pageSize;
        });
      } else {
        setState(() => _hasMore = false);
      }
    } on FirebaseException catch (e) {
      _showError(e.message ?? 'Failed to load more.');
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _refresh);
  }

  void _onClearSearch() {
    _searchController.clear();
    _refresh();
  }

  void _onCategorySelected(String c) {
    if (_selectedCategory == c) return;
    setState(() => _selectedCategory = c);
    _refresh();
  }

  void _openDetail(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailPage(destinationId: doc.id),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlacesScreen._bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (_isLoading && _docs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_docs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No destinations found',
                      style: TextStyle(color: PlacesScreen._muted),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: _docs.length,
                  itemBuilder: (_, index) {
                    final dest = _Destination.fromDoc(_docs[index]);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 330),
                          child: _DestinationCard(
                            dest: dest,
                            imageHeight: 180,
                            onTap: () => _openDetail(_docs[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              SliverToBoxAdapter(child: _buildLoadMore()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        _ExploreHeader(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onClear: _onClearSearch,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryRow(
                categories: _categories,
                selected: _selectedCategory,
                onSelected: _onCategorySelected,
                total: _docs.length,
                hasMore: _hasMore,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMore() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasMore) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ElevatedButton(
        onPressed: _loadMore,
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        child: const Text('Load more destinations'),
      ),
    );
  }
}

/* ========================= Header ========================= */

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: PlacesScreen._brandBlue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Explore Destinations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 300,
                child: Text(
                  "Discover Ethiopia's most remarkable places and hidden gems",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xFF5F6B7A),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onChanged: onChanged,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Search destinations',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: onClear,
                          child: const Icon(
                            Icons.clear,
                            size: 18,
                            color: Color(0xFF5F6B7A),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ========================= Category Row ========================= */

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.total,
    required this.hasMore,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final int total;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Showing $total${hasMore ? "+" : ""} destinations',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_titleCase(c)),
                      selected: selected == c,
                      onSelected: (_) => onSelected(c),
                      selectedColor: PlacesScreen._buttonBlue.withOpacity(0.12),
                      labelStyle: TextStyle(
                        color: selected == c
                            ? PlacesScreen._buttonBlue
                            : PlacesScreen._dark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/* ========================= Destination Card ========================= */

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.dest,
    this.imageHeight = 150,
    required this.onTap,
  });
  final _Destination dest;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: PlacesScreen._cardBorder),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(dest: dest, height: imageHeight),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dest.title,
                    style: const TextStyle(
                      color: PlacesScreen._dark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dest.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PlacesScreen._muted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Explore More →',
                        style: TextStyle(
                          color: PlacesScreen._buttonBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.dest, required this.height});
  final _Destination dest;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasImageUrl = dest.imageUrl.isNotEmpty;
    final imageWidget = hasImageUrl
        ? Image.network(
            dest.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: PlacesScreen._placeholderColor),
          )
        : Container(color: PlacesScreen._placeholderColor);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imageWidget,
            ),
          ),
          if (dest.badge.isNotEmpty)
            Positioned(
              top: 8,
              left: 8,
              child: _Badge(
                label: dest.badge,
                color: dest.badge.toLowerCase().contains('popular')
                    ? PlacesScreen._red
                    : PlacesScreen._orange,
              ),
            ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: PlacesScreen._cardBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _titleCase(
                  dest.category.isNotEmpty ? dest.category : 'Explore',
                ),
                style: const TextStyle(
                  color: PlacesScreen._dark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

/* ========================= Load More CTA ========================= */

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: PlacesScreen._buttonBlue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Load More destination',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ========================= Data Model ========================= */

class _Destination {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String badge;
  final double rating;

  const _Destination({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.badge,
    required this.rating,
  });

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static _Destination fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final name = (data['title'] ?? data['name'] ?? '').toString().trim();
    final description = (data['description'] ?? data['story'] ?? '')
        .toString()
        .trim();
    final imageUrl =
        (data['imageUrl'] ??
                data['heroImage'] ??
                data['thumbnail'] ??
                data['image'] ??
                '')
            .toString()
            .trim();
    final category = (data['category'] ?? '').toString().trim();
    final badge = (data['badge'] ?? '').toString().trim();
    final rating = _toDouble(data['rating']) ?? 4.5;

    return _Destination(
      id: doc.id,
      title: name.isNotEmpty ? name : doc.id,
      description: description.isNotEmpty
          ? description
          : 'Discover this destination in Ethiopia',
      imageUrl: imageUrl,
      category: category.isNotEmpty ? category : 'Explore',
      badge: badge,
      rating: rating,
    );
  }
}

/* ========================= Helpers ========================= */

String _titleCase(String input) {
  final words = input.trim().split(RegExp(r'\s+'));
  return words
      .map(
        (w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
      )
      .join(' ');
}
