import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../services/business_service.dart';

class BusinessProvider extends ChangeNotifier {
  List<BusinessModel> _businesses = [];
  List<BusinessModel> _recommendedBusinesses = [];
  bool _isLoading = false;
  String? _error;

  List<BusinessModel> get businesses => _businesses;
  List<BusinessModel> get recommendedBusinesses => _recommendedBusinesses;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> refreshBusiness(String businessId) async {
    try {
      final updated = await BusinessService.instance.getBusinessById(businessId);
      final idx = _businesses.indexWhere((b) => b.id == businessId);
      if (idx != -1) { _businesses[idx] = updated; notifyListeners(); }
      final rIdx = _recommendedBusinesses.indexWhere((b) => b.id == businessId);
      if (rIdx != -1) { _recommendedBusinesses[rIdx] = updated; notifyListeners(); }
    } catch (_) {}
  }
}
