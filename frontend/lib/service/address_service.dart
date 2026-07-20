import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';

class AddressService {
  static const _globalKey = 'rr_shipping_addresses_v1';

  static Future<String> _keyForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email');
    if (email != null && email.isNotEmpty) {
      return 'rr_shipping_addresses_v1:$email';
    }
    return _globalKey;
  }

  static Future<List<Address>> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _keyForCurrentUser();
    final raw = prefs.getString(key);

    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((item) => Address.fromMap((item as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAddresses(List<Address> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _keyForCurrentUser();
    final payload = json.encode(addresses.map((e) => e.toMap()).toList());
    await prefs.setString(key, payload);
  }

  static Future<void> clearAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _keyForCurrentUser();
    await prefs.remove(key);
  }
}
