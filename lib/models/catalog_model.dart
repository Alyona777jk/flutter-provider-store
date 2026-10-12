import 'package:flutter/foundation.dart';
import '../services/fake_api.dart';

enum LoadingState { initial, loading, loaded, error }

class CatalogModel extends ChangeNotifier {
  final FakeApi _api = FakeApi();

  List<Product> _products = [];
  LoadingState _state = LoadingState.initial;
  String _errorMessage = '';
  String _selectedCategory = 'Усі';

  List<Product> get products {
    if (_selectedCategory == 'Усі') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  List<String> get categories => ['Усі', 'Електроніка', 'Одяг', 'Книги'];
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  Future<void> loadProducts() async {
    _state = LoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await _api.fetchProducts();
      _state = LoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}