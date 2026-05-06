import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
    final data = await _api.get('/reviews/business/$businessId');
    final List<dynamic> json = data['reviews'] ?? data['data'] ?? (data is List ? data : []);
    return json.cast<Map<String, dynamic>>();
  }

  // Métodos para el Dueño del Negocio (Business Owner)
  Future<BusinessModel> getMyBusiness() async {
    final data = await _api.get('/businesses/mine');
    return BusinessModel.fromJson((data['business'] ?? data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getBusinessMetrics({int? month, int? year}) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;
    
    final data = await _api.get('/businesses/metrics', queryParams: queryParams);
    return (data['metrics'] ?? data['data'] ?? data) as Map<String, dynamic>;
  }

  Future<List<AppointmentModel>> getBusinessReservations({String? date}) async {
    final query = date != null ? '?date=$date' : '';
    final data = await _api.get('/businesses/reservations$query');
    final List<dynamic> json = data['reservations'] ?? data['data'] ?? (data is List ? data : []);
    return json.map((j) => AppointmentModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<ServiceModel> createService({
    required String name,
    required int durationMinutes,
    required double price,
  }) async {
    final data = await _api.post('/services', body: {
      'name': name,
      'durationMinutes': durationMinutes,
      'price': price,
    });
    return ServiceModel.fromJson((data['service'] ?? data['data'] ?? data) as Map<String, dynamic>);
  }

  // requires api_service to support multipart, or use http directly. Since ApiService doesn't seem to have it, 
  Future<String> uploadServicePhoto(String serviceId, File file) async {
    final data = await _api.uploadFile('/services/$serviceId/photo', file, fieldName: 'photo', method: 'PATCH');
    return data['photo_url'] as String;
  }

  Future<BusinessModel> updateBusiness({
    String? name,
    String? type,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (type != null) body['type'] = _frontendToBackend[type] ?? type.toUpperCase();
    if (address != null) body['address'] = address;
    if (phone != null) body['phone'] = phone;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    final data = await _api.put('/businesses/mine', body: body);
    return BusinessModel.fromJson((data['business'] ?? data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<String> uploadBusinessLogo(File file) async {
    final data = await _api.uploadFile('/businesses/mine/logo', file, fieldName: 'logo', method: 'PATCH');
    return data['logo_url'] as String;
  }

  Future<List<String>> uploadBusinessPhotos(List<File> files) async {
    // Note: MultipartRequest usually supports multiple files but ApiService.uploadFile supports one.
    // I'll add a multi-upload logic here or loop. For simplicity, let's use a loop or update ApiService.
    // Given the backend expects an array 'photos', I should probably use a single request.
    
    final uri = Uri.parse('${ApiService.instance.baseUrl}/businesses/mine/photos');
    final request = http.MultipartRequest('PUT', uri);
    
    // Add headers
    final hdrs = await ApiService.instance.headers();
    hdrs.remove('Content-Type');
    request.headers.addAll(hdrs);
    
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('photos', file.path));
    }
    
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final List<dynamic> photos = body['photos'] ?? [];
      return photos.cast<String>();
    } else {
      throw Exception('Error uploading photos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getMySchedules() async {
    final data = await _api.get('/schedules');
    return data as Map<String, dynamic>;
  }

  Future<void> upsertSchedule({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    await _api.put('/schedules', body: {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    });
  }

  Future<void> removeSchedule(String id) async {
    await _api.delete('/schedules/$id');
  }

  Future<ServiceModel> updateService(
    String serviceId, {
    String? name,
    int? durationMinutes,
    double? price,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (durationMinutes != null) body['durationMinutes'] = durationMinutes;
    if (price != null) body['price'] = price;

    final data = await _api.put('/services/$serviceId', body: body);
    return ServiceModel.fromJson((data['service'] ?? data['data'] ?? data) as Map<String, dynamic>);
  }
}
