import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evenstage_mobile/services/audio_service.dart';
import 'package:evenstage_mobile/models/track.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search artists, tracks...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: _updateSearchQuery,
                  )
                : Text(
                    'Search',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.clear : Icons.search),
                onPressed: () {
                  if (_isSearching) {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                  } else {
                    _startSearch();
                  }
                },
              ),
            ],
          ),
          
          // Search Results or Categories
          _isSearching && _searchQuery.isNotEmpty
              ? _buildSearchResults()
              : _buildBrowseCategories(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Mock search results
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Alternate between artists and tracks
          if (index % 2 == 0) {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CachedNetworkImage(
                  imageUrl: 'https://picsum.photos/seed/${index + 50}/50/50',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text('Artist matching "$_searchQuery"'),
              subtitle: const Text('Artist'),
              onTap: () {
                // Navigate to artist
              },
            );
          } else {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: 'https://picsum.photos/seed/${index + 100}/50/50',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text('Track matching "$_searchQuery"'),
              subtitle: const Text('Artist • Track'),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_filled),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  // Play track
                },
              ),
              onTap: () {
                // Navigate to track
              },
            );
          }
        },
        childCount: 10,
      ),
    );
  }

  Widget _buildBrowseCategories() {
    // Genre categories
    final categories = [
      'Rock',
      'Pop',
      'Hip Hop',
      'Electronic',
      'Jazz',
      'Classical',
      'Country',
      'R&B',
      'Indie',
      'Metal',
      'Folk',
      'Blues',
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Browse All',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  // Navigate to category
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}