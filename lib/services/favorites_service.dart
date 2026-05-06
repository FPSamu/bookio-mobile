import 'api_service.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();
  final ApiService _api = ApiService.instance;

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final data = await _api.get('/favorites');
    final List<dynamic> json = data['favorites'] ?? (data is List ? data : []);
    return json.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> addFavorite(String businessId) async {
    final data = await _api.post('/favorites', body: {'businessId': businessId});
    return (data['favorite'] ?? data) as Map<String, dynamic>;
  }

  Future<void> removeFavorite(String favoriteEntryId) async {
    await _api.delete('/favorites/$favoriteEntryId');
  }
}
