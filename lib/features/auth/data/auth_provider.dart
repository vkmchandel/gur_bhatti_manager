import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/bhatti_model.dart';

class AuthProvider extends ChangeNotifier {
  BhattiModel? _bhatti;
  String? _tempMobile;
  bool _isAuthenticated = false;
  static const String _bhattiKey = 'active_bhatti';

  AuthProvider() {
    _loadBhatti();
  }

  BhattiModel? get bhatti => _bhatti;
  String? get tempMobile => _tempMobile;
  bool get isAuthenticated => _isAuthenticated || _bhatti != null;

  Future<void> _loadBhatti() async {
    final prefs = await SharedPreferences.getInstance();
    final bhattiJson = prefs.getString(_bhattiKey);
    if (bhattiJson != null) {
      _bhatti = BhattiModel.fromJson(jsonDecode(bhattiJson));
      notifyListeners();
    }
  }

  Future<void> login(String mobileNumber) async {
    // Mocking OTP verification success
    _tempMobile = mobileNumber;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> setupBhatti(BhattiModel bhatti) async {
    _bhatti = bhatti;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bhattiKey, jsonEncode(bhatti.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _bhatti = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bhattiKey);
    notifyListeners();
  }
}
