import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'fees_list_screen.dart';
import 'insights_screen.dart';
import 'models.dart';
import 'reports_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WebSocketChannel? _channel;
  bool _wsConnected = false;

  @override
  void initState() {
    super.initState();
    // Connect WebSocket after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectWebSocket();
    });
  }

  void _connectWebSocket() {
    try {
      debugPrint('Attempting to connect WebSocket to ws://10.0.2.2:2620');
      // Use IOWebSocketChannel for mobile platforms to ensure a proper socket connection.
      _channel = IOWebSocketChannel.connect('ws://10.0.2.2:2620');
      debugPrint('WebSocket channel created, setting up listener...');
      _channel!.stream.listen(
        (message) {
          if (!_wsConnected) {
            setState(() {
              _wsConnected = true;
            });
            debugPrint('WebSocket connection confirmed!');
          }
          debugPrint('WebSocket message received: $message');
          try {
            final data = jsonDecode(message as String) as Map<String, dynamic>;
            final fee = Fee.fromJson(data);
            debugPrint('Parsed fee from WebSocket: ${fee.id} - ${fee.type}');
            // Show a simple global notification when a new fee is added.
            _showNewFeeNotification(fee);
          } catch (e) {
            debugPrint('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket stream error: $error');
          if (mounted) {
            setState(() {
              _wsConnected = false;
            });
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          if (mounted) {
            setState(() {
              _wsConnected = false;
            });
          }
          // Try to reconnect after a delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              debugPrint('Attempting to reconnect WebSocket...');
              _connectWebSocket();
            }
          });
        },
        cancelOnError: false,
      );
      debugPrint('WebSocket listener set up successfully');
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
      // Try to reconnect after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          debugPrint('Retrying WebSocket connection...');
          _connectWebSocket();
        }
      });
    }
  }

  void _showNewFeeNotification(Fee fee) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'New fee added: ${fee.type} ${fee.amount.toStringAsFixed(2)} on ${fee.date}',
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fee Management Exam App',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FeesListScreen()),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('View Fees (List)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('Monthly Fee Analysis'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InsightsScreen()),
                );
              },
              icon: const Icon(Icons.insights),
              label: const Text('Top Categories'),
            ),
          ],
        ),
      ),
    );
  }
}

