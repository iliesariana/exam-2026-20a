import 'package:flutter/material.dart';

import 'fee_repository.dart';
import 'models.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final FeeRepository _repository = FeeRepository();
  late Future<List<CategoryTotal>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = _loadData();
  }

  Future<List<CategoryTotal>> _loadData() async {
    final fees = await _repository.getAllFees();
    return _repository.computeTopCategories(fees);
  }

  void _retry() {
    setState(() {
      _futureCategories = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Fee Categories'),
      ),
      body: FutureBuilder<List<CategoryTotal>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load insights.\nIf you are offline and data was never loaded before, try again when online.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(
              child: Text('No data available.'),
            );
          }
          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = categories[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item.category),
                trailing: Text(
                  item.total.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

