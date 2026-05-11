import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_model.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- RECENT BUSINESSES ---

  List<BusinessModel> getRecentBusinesses() {
    if (_prefs == null) return [];
    final jsonList = _prefs!.getStringList('recent_businesses') ?? [];
    return jsonList.map((str) => BusinessModel.fromJson(jsonDecode(str))).toList();
  }

  Future<void> addRecentBusiness(BusinessModel business) async {
    if (_prefs == null) return;
    final currentList = getRecentBusinesses();
    currentList.removeWhere((b) => b.id == business.id);
    currentList.insert(0, business);
    if (currentList.length > 10) currentList.removeLast();
    final jsonList = currentList.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs!.setStringList('recent_businesses', jsonList);
  }

  // --- FAVORITES ---

  List<BusinessModel> getFavorites() {
    if (_prefs == null) return [];
    final jsonList = _prefs!.getStringList('favorite_businesses') ?? [];
    return jsonList.map((str) => BusinessModel.fromJson(jsonDecode(str))).toList();
  }

  Future<void> toggleFavorite(BusinessModel business) async {
    if (_prefs == null) return;
    final favs = getFavorites();
    if (favs.any((b) => b.id == business.id)) {
      favs.removeWhere((b) => b.id == business.id);
    } else {
      favs.add(business);
    }
    final jsonList = favs.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs!.setStringList('favorite_businesses', jsonList);
  }

  bool isFavorite(String businessId) {
    return getFavorites().any((b) => b.id == businessId);
  }

  // --- APPOINTMENT RATINGS ---

  Map<String, dynamic> _getRatingsMap() {
    if (_prefs == null) return {};
    final raw = _prefs!.getString('appointment_ratings') ?? '{}';
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  double? getAppointmentRating(String appointmentId) {
    final ratings = _getRatingsMap();
    final entry = ratings[appointmentId];
    if (entry == null) return null;
    return (entry['rating'] as num?)?.toDouble();
  }

  String? getAppointmentReview(String appointmentId) {
    final ratings = _getRatingsMap();
    final entry = ratings[appointmentId];
    return entry?['review'] as String?;
  }

  Future<void> saveAppointmentRating(String appointmentId, double rating, {String? review}) async {
    if (_prefs == null) return;
    final ratings = _getRatingsMap();
    ratings[appointmentId] = {'rating': rating, 'review': review};
    await _prefs!.setString('appointment_ratings', jsonEncode(ratings));
  }

  // --- NOTIFICATION PREFERENCES ---

  Map<String, bool> getNotificationPrefs() {
    if (_prefs == null) {
      return {'new_appointment': true, 'reminder': true, 'cancellation': true, 'news': false};
    }
    return {
      'new_appointment': _prefs!.getBool('notif_new_appointment') ?? true,
      'reminder': _prefs!.getBool('notif_reminder') ?? true,
      'cancellation': _prefs!.getBool('notif_cancellation') ?? true,
      'news': _prefs!.getBool('notif_news') ?? false,
    };
  }

  Future<void> setNotificationPref(String key, bool value) async {
    await _prefs?.setBool('notif_$key', value);
  }

}
