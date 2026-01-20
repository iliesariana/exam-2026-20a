import 'package:flutter/material.dart';

import 'fee_repository.dart';
import 'models.dart';
import 'fee_detail_screen.dart';
import 'fee_form_screen.dart';

class FeesListScreen extends StatefulWidget {
  const FeesListScreen({super.key});

  @override
  State<FeesListScreen> createState() => _FeesListScreenState();
}

class _FeesListScreenState extends State<FeesListScreen> {
  final FeeRepository _repository = FeeRepository();
  late Future<List<Fee>> _futureFees;

  @override
  void initState() {
    super.initState();
    _futureFees = _repository.getFees();
  }

  void _retry() {
    setState(() {
      _futureFees = _repository.getFees();
    });
  }

  Future<void> _deleteFee(Fee fee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee'),
        content: Text('Are you sure you want to delete fee #${fee.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _repository.deleteFee(fee.id);
      if (!mounted) return;
      Navigator.of(context).pop(); // close progress
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fee deleted successfully (online only).')),
      );
      setState(() {
        _futureFees = _repository.getFees();
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // close progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting fee (online only): $e')),
      );
    }
  }

  Future<void> _navigateToAdd() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const FeeFormScreen()),
    );
    if (added == true) {
      setState(() {
        _futureFees = _repository.getFees();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees List'),
      ),
      body: FutureBuilder<List<Fee>>(
        future: _futureFees,
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
                    const Icon(Icons.wifi_off, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'You appear to be offline or the server is unreachable.',
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

          final fees = snapshot.data ?? [];
          if (fees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No fees available.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _retry();
              await _futureFees;
            },
            child: ListView.separated(
              itemCount: fees.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final fee = fees[index];
                return ListTile(
                  title: Text('${fee.type} - ${fee.amount.toStringAsFixed(2)}'),
                  subtitle: Text('${fee.category} • ${fee.date}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFee(fee),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FeeDetailScreen(feeId: fee.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

