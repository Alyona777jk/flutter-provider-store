import 'package:flutter/foundation.dart';
import '../services/fake_api.dart';

enum PaymentMethod { card, cash }

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  final FakeApi _api = FakeApi();
  final Map<String, CartItem> _items = {};
  bool _isOrdering = false;
  String? _orderError;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;

  Map<String, CartItem> get items => {..._items};
  bool get isOrdering => _isOrdering;
  String? get orderError => _orderError;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  int get totalItemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int delta) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    item.quantity += delta;
    if (item.quantity <= 0) {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  Future<bool> placeOrder() async {
    if (_items.isEmpty || _isOrdering) return false;

    _isOrdering = true;
    _orderError = null;
    notifyListeners();

    try {
      final methodTitle = _selectedPaymentMethod == PaymentMethod.card ? 'Карткою' : 'Готівкою';
      await _api.checkout(methodTitle);
      _items.clear();
      _isOrdering = false;
      notifyListeners();
      return true;
    } catch (e) {
      _orderError = e.toString().replaceAll('Exception: ', '');
      _isOrdering = false;
      notifyListeners();
      return false;
    }
  }
}