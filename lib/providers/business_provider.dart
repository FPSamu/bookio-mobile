import 'package:flutter/material.dart';
import 'dart:io';
import '../models/business_model.dart';
import '../models/appointment_model.dart';
import '../services/business_service.dart';
import '../services/favorites_service.dart';

class BusinessProvider extends ChangeNotifier {
  List<BusinessModel> _businesses = [];
  List<BusinessModel> _recommendedBusinesses = [];
  bool _isLoading = false;
  String? _error;

  // favorites: maps businessId -> favoriteEntryId
  final Map<String, String> _favoriteIds = {};
  List<BusinessModel> _favoriteBusinesses = [];
  bool _favoritesLoading = false;

  // Owner State
  BusinessModel? _myBusiness;
  Map<String, dynamic>? _myMetrics;
  List<AppointmentModel>? _myReservations;

  List<BusinessModel> get businesses => _businesses;
  List<BusinessModel> get recommendedBusinesses => _recommendedBusinesses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BusinessModel> get favoriteBusinesses => _favoriteBusinesses;
  bool get favoritesLoading => _favoritesLoading;
  bool isFavorite(String businessId) => _favoriteIds.containsKey(businessId);

  BusinessModel? get myBusiness => _myBusiness;
  Map<String, dynamic>? get myMetrics => _myMetrics;
  List<AppointmentModel>? get myReservations => _myReservations;

  void clear() {
    _businesses = [];
    _recommendedBusinesses = [];
    _myBusiness = null;
    _myMetrics = null;
    _myReservations = null;
    _favoriteIds.clear();
    _favoriteBusinesses = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> fetchBusinesses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _businesses = await BusinessService.instance.getAllBusinesses();
      _recommendedBusinesses = await BusinessService.instance.getRecommendedBusinesses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBusinessesByType(String type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _businesses = await BusinessService.instance.getAllBusinesses(type: type);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<BusinessModel>> searchBusinessesWithFilters({
    required String query,
    String? type,
    double? ratingGte,
  }) async {
    return await BusinessService.instance.getAllBusinesses(
      search: query,
      type: type,
      ratingGte: ratingGte,
    );
  }

  Future<void> fetchFavorites() async {
    _favoritesLoading = true;
    notifyListeners();
    try {
      final raw = await FavoritesService.instance.getFavorites();
      _favoriteIds.clear();
      _favoriteBusinesses = [];
      for (final f in raw) {
        final favoriteId = f['id'] as String?;
        final businessData = f['business'] as Map<String, dynamic>?;
        if (favoriteId == null || businessData == null) continue;
        final business = BusinessModel.fromJson(businessData);
        _favoriteIds[business.id] = favoriteId;
        _favoriteBusinesses.add(business);
      }
    } catch (_) {
    } finally {
      _favoritesLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String businessId, BusinessModel business) async {
    if (_favoriteIds.containsKey(businessId)) {
      final entryId = _favoriteIds[businessId]!;
      _favoriteIds.remove(businessId);
      _favoriteBusinesses.removeWhere((b) => b.id == businessId);
      notifyListeners();
      try {
        await FavoritesService.instance.removeFavorite(entryId);
      } catch (_) {
        _favoriteIds[businessId] = entryId;
        _favoriteBusinesses.insert(0, business);
        notifyListeners();
      }
    } else {
      _favoriteIds[businessId] = '';
      _favoriteBusinesses.insert(0, business);
      notifyListeners();
      try {
        final result = await FavoritesService.instance.addFavorite(businessId);
        final newId = result['id'] as String?;
        if (newId != null) _favoriteIds[businessId] = newId;
      } catch (_) {
        _favoriteIds.remove(businessId);
        _favoriteBusinesses.removeWhere((b) => b.id == businessId);
        notifyListeners();
      }
    }
  }

  Future<void> refreshBusiness(String businessId) async {
    try {
      final updated = await BusinessService.instance.getBusinessById(businessId);
      final idx = _businesses.indexWhere((b) => b.id == businessId);
      if (idx != -1) { _businesses[idx] = updated; notifyListeners(); }
      final rIdx = _recommendedBusinesses.indexWhere((b) => b.id == businessId);
      if (rIdx != -1) { _recommendedBusinesses[rIdx] = updated; notifyListeners(); }
    } catch (_) {}
  }

  // Métodos del Dueño (Owner)
  Future<void> fetchMyBusinessData() async {
    try {
      _myBusiness = await BusinessService.instance.getMyBusiness();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchMyMetrics({int? month, int? year}) async {
    try {
      _myMetrics = await BusinessService.instance.getBusinessMetrics(month: month, year: year);
      debugPrint('--- METRICS RECEIVED: $_myMetrics');
      notifyListeners();
    } catch (e) {
      debugPrint('--- ERROR FETCHING METRICS: $e');
    }
  }

  Future<void> fetchMyReservations({String? date}) async {
    try {
      _myReservations = await BusinessService.instance.getBusinessReservations(date: date);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> createService({
    required String name,
    required int durationMinutes,
    required double price,
    File? photo,
  }) async {
    try {
      final service = await BusinessService.instance.createService(
        name: name,
        durationMinutes: durationMinutes,
        price: price,
      );
      if (photo != null) {
        await BusinessService.instance.uploadServicePhoto(service.id, photo);
      }
      await fetchMyBusinessData(); // Refresh local business data
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBusiness({
    String? name,
    String? type,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    try {
      _myBusiness = await BusinessService.instance.updateBusiness(
        name: name,
        type: type,
        address: address,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadLogo(File photo) async {
    try {
      final logoUrl = await BusinessService.instance.uploadBusinessLogo(photo);
      if (_myBusiness != null) {
        _myBusiness = _myBusiness!.copyWith(logoUrl: logoUrl);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadPhotos(List<File> photos) async {
    try {
      final photoUrls = await BusinessService.instance.uploadBusinessPhotos(photos);
      if (_myBusiness != null) {
        _myBusiness = _myBusiness!.copyWith(photos: photoUrls);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateService(
    String serviceId, {
    String? name,
    int? durationMinutes,
    double? price,
    File? photo,
  }) async {
    try {
      await BusinessService.instance.updateService(
        serviceId,
        name: name,
        durationMinutes: durationMinutes,
        price: price,
      );
      if (photo != null) {
        await BusinessService.instance.uploadServicePhoto(serviceId, photo);
      }
      await fetchMyBusinessData();
    } catch (e) {
      rethrow;
    }
  }
}
