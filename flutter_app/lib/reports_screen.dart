import 'package:flutter/material.dart';

import 'fee_repository.dart';
import 'models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FeeRepository _repository = FeeRepository();
  late Future<List<MonthlyTotal>> _futureTotals;

  @override
  void initState() {
    super.initState();
    _futureTotals = _loadData();
  }

  Future<List<MonthlyTotal>> _loadData() async {
    final fees = await _repository.getAllFees();
    return _repository.computeMonthlyTotals(fees);
  }

  void _retry() {
    setState(() {
      _futureTotals = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Fee Analysis'),
      ),
      body: FutureBuilder<List<MonthlyTotal>>(
        future: _futureTotals,
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
                      'Unable to load report.\nIf you are offline and data was never loaded before, try again when online.',
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
          final totals = snapshot.data ?? [];
          if (totals.isEmpty) {
            return const Center(
              child: Text('No data available.'),
            );
          }
          return ListView.separated(
            itemCount: totals.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = totals[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item.month),
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

