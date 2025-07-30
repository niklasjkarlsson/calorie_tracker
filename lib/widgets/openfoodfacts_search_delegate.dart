import 'dart:async';
import 'package:flutter/material.dart';
import '../api.dart';

class OpenFoodFactsSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  Timer? _debounce;
  Future<List<Map<String, dynamic>>>? _searchFuture;
  String _lastQuery = '';

  void _triggerSearch() {
    if (query == _lastQuery) return;

    _lastQuery = query;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchFuture = OpenFoodFactsAPI.fetchProductByName(query);
      // We trigger a rebuild by calling showResults (hacky but works for debouncing)
      // Instead: Just call `buildSuggestions` again by updating `query`
      query = query; // triggers `buildSuggestions` again
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _searchFuture = null;
            _lastQuery = '';
            showSuggestions(context);
          },
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Start typing to search.'));
    }

    _triggerSearch();

    if (_searchFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data;

        if (results == null || results.isEmpty) {
          return const Center(child: Text('No suggestions found.'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            final name = product['product_name'] ?? 'Unnamed product';
            final brand = product['brands'] ?? 'Unknown';
            final kcal = product['nutriments']?['energy-kcal_100g']?.toString() ?? 'N/A';

            return ListTile(
              title: Text(name),
              subtitle: Text('$brand — $kcal kcal/100g'),
              onTap: () => close(context, product),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // You can reuse suggestions here if you want.
    return buildSuggestions(context);
  }
}
