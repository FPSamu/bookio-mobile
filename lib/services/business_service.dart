import 'api_service.dart';

/// Servicio de negocios — equivalente al `businesses.js` del frontend React.
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

  /// Registra un negocio nuevo en el backend.
  Future<Map<String, dynamic>> registerBusiness({
    required String name,
    required String type,
    String? address,
  }) async {
    final backendType = _frontendToBackend[type] ?? type.toUpperCase();

    final data = await _api.post('/businesses', body: {
      'name': name,
      'type': backendType,
      if (address != null && address.isNotEmpty) 'address': address,
    });

    return data as Map<String, dynamic>;
  }
}
