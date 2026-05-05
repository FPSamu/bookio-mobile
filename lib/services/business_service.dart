import '../models/business_model.dart';
import '../models/appointment_model.dart';
import 'api_service.dart';

class BusinessService {
  BusinessService._();
  static final BusinessService instance = BusinessService._();

  final ApiService _api = ApiService.instance;

  static const _frontendToBackend = <String, String>{
    'restaurant': 'RESTAURANT',
    'spa':        'SPA',
    'salon':      'SALON',
    'medical':    'MEDICAL',
    'barbershop': 'BARBERSHOP',
    'other':      'OTHER',
  };

  Future<Map<String, dynamic>> registerBusiness({
    required String name,
    required String type,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final backendType = _frontendToBackend[type] ?? type.toUpperCase();
    final data = await _api.post('/businesses', body: {
      'name': name,
      'type': backendType,
      if (address != null && address.isNotEmpty) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return data as Map<String, dynamic>;
  }

  Future<List<BusinessModel>> getAllBusinesses({String? search, String? type, double? ratingGte}) async {
    final queryParams = <String>[];
    if (search != null && search.isNotEmpty) queryParams.add('search=$search');
    if (type != null && type.isNotEmpty) queryParams.add('type=$type');
    if (ratingGte != null) queryParams.add('ratingGte=$ratingGte');
    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final data = await _api.get('/businesses$queryString');
    final List<dynamic> json = data['data'] ?? data['businesses'] ?? (data is List ? data : []);
    return json.map((j) => BusinessModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<BusinessModel>> getRecommendedBusinesses() async {
    final data = await _api.get('/businesses/recommended');
    final List<dynamic> json = data['data'] ?? data['businesses'] ?? (data is List ? data : []);
    return json.map((j) => BusinessModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<ServiceModel>> getBusinessServices(String businessId) async {
    final data = await _api.get('/businesses/$businessId/services');
    final List<dynamic> json = data['services'] ?? data['data'] ?? (data is List ? data : []);
    return json.map((j) => ServiceModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> getBusinessSchedule(String businessId) async {
    final data = await _api.get('/schedules/business/$businessId');
    final List<dynamic> scheduleJson = data['schedules'] ?? [];
    final list = scheduleJson.cast<Map<String, dynamic>>().toList();
    list.sort((a, b) => (a['day_of_week'] as int).compareTo(b['day_of_week'] as int));
    return list;
  }

  Future<BusinessModel> getBusinessById(String businessId) async {
    final data = await _api.get('/businesses/$businessId');
    return BusinessModel.fromJson((data['business'] ?? data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getBusinessReviews(String businessId) async {
    final data = await _api.get('/businesses/$businessId/reviews');
    final List<dynamic> json = data['reviews'] ?? data['data'] ?? (data is List ? data : []);
    return json.cast<Map<String, dynamic>>();
  }
}
