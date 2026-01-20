import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

// When running on Android emulator, localhost of the host machine is 10.0.2.2.
const String _baseUrl = 'http://10.0.2.2:2620';

class FeeRepository {
  static const String _feesListKey = 'fees_list';
  static const String _allFeesKey = 'all_fees';

  Future<List<Fee>> getFees() async {
    try {
      // Add an explicit timeout so the UI doesn't wait forever
      final response = await http
          .get(Uri.parse('$_baseUrl/fees'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final fees = data.map((e) => Fee.fromJson(e as Map<String, dynamic>)).toList();
        await _cacheFeesList(fees);
        return fees;
      } else {
        throw Exception('Failed to load fees: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching fees from server: $e');
      final cached = await getCachedFees();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<Fee>> getCachedFees() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_feesListKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      return data.map((e) => Fee.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error decoding cached fees: $e');
      return [];
    }
  }

  Future<void> _cacheFeesList(List<Fee> fees) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(fees.map((e) => e.toJson()).toList());
    await prefs.setString(_feesListKey, jsonString);
  }

  Future<Fee> getFeeById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/fee/$id'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final fee = Fee.fromJson(data);
        await _cacheFee(fee);
        return fee;
      } else {
        throw Exception('Failed to load fee: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching fee from server: $e');
      final cached = await getCachedFee(id);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<void> _cacheFee(Fee fee) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fee_${fee.id}', jsonEncode(fee.toJson()));
  }

  Future<Fee?> getCachedFee(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('fee_$id');
    if (jsonString == null) return null;
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return Fee.fromJson(data);
    } catch (e) {
      debugPrint('Error decoding cached fee: $e');
      return null;
    }
  }

  Future<Fee> addFee({
    required String date,
    required double amount,
    required String type,
    required String category,
    required String description,
  }) async {
    final body = {
      'date': date,
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
    };
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/fee'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final fee = Fee.fromJson(data);
        // update cache for list and individual fee
        final current = await getCachedFees();
        final updated = [...current, fee];
        await _cacheFeesList(updated);
        await _cacheFee(fee);
        return fee;
      } else {
        throw Exception('Failed to add fee: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding fee: $e');
      rethrow;
    }
  }

  Future<void> deleteFee(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/fee/$id'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final current = await getCachedFees();
        final updated = current.where((f) => f.id != id).toList();
        await _cacheFeesList(updated);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('fee_$id');
      } else {
        throw Exception('Failed to delete fee: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting fee: $e');
      rethrow;
    }
  }

  Future<List<Fee>> getAllFees() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/allFees'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final fees = data.map((e) => Fee.fromJson(e as Map<String, dynamic>)).toList();
        await _cacheAllFees(fees);
        return fees;
      } else {
        throw Exception('Failed to load all fees: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching allFees from server: $e');
      final cached = await getCachedAllFees();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<void> _cacheAllFees(List<Fee> fees) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(fees.map((e) => e.toJson()).toList());
    await prefs.setString(_allFeesKey, jsonString);
  }

  Future<List<Fee>> getCachedAllFees() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_allFeesKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      return data.map((e) => Fee.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error decoding cached allFees: $e');
      return [];
    }
  }

  List<MonthlyTotal> computeMonthlyTotals(List<Fee> fees) {
    final Map<String, double> totals = {};
    for (final fee in fees) {
      final month = fee.date.length >= 7 ? fee.date.substring(0, 7) : fee.date;
      totals[month] = (totals[month] ?? 0) + fee.amount;
    }
    final list = totals.entries
        .map((e) => MonthlyTotal(month: e.key, total: e.value))
        .toList();
    list.sort((a, b) => b.total.compareTo(a.total));
    return list;
  }

  List<CategoryTotal> computeTopCategories(List<Fee> fees, {int top = 3}) {
    final Map<String, double> totals = {};
    for (final fee in fees) {
      final key = fee.category.isEmpty ? 'uncategorized' : fee.category;
      totals[key] = (totals[key] ?? 0) + fee.amount;
    }
    final list = totals.entries
        .map((e) => CategoryTotal(category: e.key, total: e.value))
        .toList();
    list.sort((a, b) => b.total.compareTo(a.total));
    if (list.length > top) {
      return list.sublist(0, top);
    }
    return list;
  }
}

