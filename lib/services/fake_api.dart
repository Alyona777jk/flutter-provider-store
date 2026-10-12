import 'dart:math';

class Product {
  final String id;
  final String title;
  final double price;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
  });
}

final List<Product> demoProducts = [
  const Product(id: '1', title: 'Смартфон', price: 25000, category: 'Електроніка'),
  const Product(id: '2', title: 'Ноутбук', price: 45000, category: 'Електроніка'),
  const Product(id: '3', title: 'Кросівки', price: 3200, category: 'Одяг'),
  const Product(id: '4', title: 'Джинси', price: 1800, category: 'Одяг'),
  const Product(id: '5', title: 'Книга Flutter', price: 850, category: 'Книги'),
];

class FakeApi {
  final _random = Random();

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextInt(5) == 0) {
      throw Exception('Сервер недоступний'); // ~кожен 5-й запит
    }
    return demoProducts;
  }

  Future<void> checkout() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextInt(5) == 0) {
      throw Exception('Помилка проведення платежу');
    }
  }
}import 'dart:math';

class Product {
  final String id;
  final String title;
  final double price;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
  });
}

final List<Product> demoProducts = [
  const Product(id: '1', title: 'Смартфон', price: 25000, category: 'Електроніка'),
  const Product(id: '2', title: 'Ноутбук', price: 45000, category: 'Електроніка'),
  const Product(id: '3', title: 'Кросівки', price: 3200, category: 'Одяг'),
  const Product(id: '4', title: 'Джинси', price: 1800, category: 'Одяг'),
  const Product(id: '5', title: 'Книга Flutter', price: 850, category: 'Книги'),
];

class FakeApi {
  final _random = Random();

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextInt(5) == 0) {
      throw Exception('Сервер недоступний'); // ~кожен 5-й запит
    }
    return demoProducts;
  }

  Future<void> checkout() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextInt(5) == 0) {
      throw Exception('Помилка проведення платежу');
    }
  }
}