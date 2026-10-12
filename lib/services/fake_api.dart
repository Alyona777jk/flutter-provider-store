import 'dart:math';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String imageUrl;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
  });
}

final List<Product> demoProducts = [
  const Product(
    id: '1',
    title: 'Смартфон 13 Pro',
    description: 'Дисплей 120 Гц, потрійна камера та потужний процесор.',
    price: 25000,
    category: 'Електроніка',
    imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300',
  ),
  const Product(
    id: '2',
    title: 'Ноутбук XPS 15',
    description: '15-дюймовий екран, 16 ГБ ОЗП, підходить для роботи та ігор.',
    price: 45000,
    category: 'Електроніка',
    imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=300',
  ),
  const Product(
    id: '3',
    title: 'Кросівки для бігу',
    description: 'Легке та дихаюче взуття для щоденних тренувань.',
    price: 3200,
    category: 'Одяг',
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
  ),
  const Product(
    id: '4',
    title: 'Джинси Classic',
    description: 'Класичний крій, 100% бавовна, висока зносостійкість.',
    price: 1800,
    category: 'Одяг',
    imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=300',
  ),
  const Product(
    id: '5',
    title: 'Книга "Flutter in Action"',
    description: 'Практичний посібник із розробки мобільних додатків.',
    price: 850,
    category: 'Книги',
    imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=300',
  ),
];

class FakeApi {
  final _random = Random();

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextInt(10) == 0) {
      throw Exception('Сервер недоступний. Спробуйте пізніше.');
    }
    return demoProducts;
  }

  Future<void> checkout(String paymentMethod) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextInt(5) == 0) {
      throw Exception('Помилка проведения платежу ($paymentMethod)');
    }
  }
}