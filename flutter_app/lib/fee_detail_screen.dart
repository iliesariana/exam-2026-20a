import 'package:flutter/material.dart';

import 'fee_repository.dart';
import 'models.dart';

class FeeDetailScreen extends StatefulWidget {
  final int feeId;

  const FeeDetailScreen({super.key, required this.feeId});

  @override
  State<FeeDetailScreen> createState() => _FeeDetailScreenState();
}

class _FeeDetailScreenState extends State<FeeDetailScreen> {
  final FeeRepository _repository = FeeRepository();
  late Future<Fee> _futureFee;

  @override
  void initState() {
    super.initState();
    _futureFee = _repository.getFeeById(widget.feeId);
  }

  void _retry() {
    setState(() {
      _futureFee = _repository.getFeeById(widget.feeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee #${widget.feeId}'),
      ),
      body: FutureBuilder<Fee>(
        future: _futureFee,
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
                      'Unable to load fee details.\nIf you are offline and details were never loaded before, try again when online.',
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
          final fee = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Date'),
                subtitle: Text(fee.date),
              ),
              ListTile(
                title: const Text('Amount'),
                subtitle: Text(fee.amount.toStringAsFixed(2)),
              ),
              ListTile(
                title: const Text('Type'),
                subtitle: Text(fee.type),
              ),
              ListTile(
                title: const Text('Category'),
                subtitle: Text(fee.category),
              ),
              ListTile(
                title: const Text('Description'),
                subtitle: Text(fee.description.isEmpty ? '-' : fee.description),
              ),
            ],
          );
        },
      ),
    );
  }
}

