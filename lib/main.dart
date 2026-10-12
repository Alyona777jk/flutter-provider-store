import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/catalog_model.dart';
import 'models/cart_model.dart';
import 'services/fake_api.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogModel()..loadProducts()),
        ChangeNotifierProvider(create: (_) => CartModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Store',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const CatalogScreen(),
    );
  }
}

// Бейдж кошика для AppBar
class CartBadgeIconButton extends StatelessWidget {
  const CartBadgeIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    // В оптимізованій версії використовуємо Selector
    return Selector<CartModel, int>(
      selector: (_, cart) => cart.totalItemCount,
      builder: (context, count, child) {
        debugPrint('[BUILD] CartBadgeIconButton build() called');
        return Badge(
          label: Text('$count'),
          isLabelVisible: count > 0,
          child: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        );
      },
    );
  }
}

// Головний екран каталогу
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] CatalogScreen build() called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товарів'),
        actions: const [CartBadgeIconButton()],
      ),
      body: Column(
        children: [
          const CategoryFilterWidget(),
          Expanded(child: const ProductListWidget()),
        ],
      ),
    );
  }
}

class CategoryFilterWidget extends StatelessWidget {
  const CategoryFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Використання context.watch для отримання обраної категорії
    final catalog = context.watch<CatalogModel>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: catalog.categories.map((category) {
          final isSelected = catalog.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                // Використання context.read у колбеку
                context.read<CatalogModel>().setCategory(category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogModel>(
      builder: (context, catalog, _) {
        if (catalog.state == LoadingState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (catalog.state == LoadingState.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Помилка: ${catalog.errorMessage}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<CatalogModel>().loadProducts(),
                  child: const Text('Повторити'),
                ),
              ],
            ),
          );
        }

        final products = catalog.products;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductTile(product: product);
          },
        );
      },
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] ProductTile (${product.title}) build() called');
    return ListTile(
      title: Text(product.title),
      subtitle: Text('${product.price} грн | ${product.category}'),
      trailing: ElevatedButton(
        onPressed: () {
          context.read<CartModel>().addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.title} додано до кошика!'), duration: const Duration(seconds: 1)),
          );
        },
        child: const Text('До кошика'),
      ),
    );
  }
}

// Екран кошика
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кошик')),
      body: Consumer<CartModel>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Кошик порожній'));
          }
          final items = cart.items.values.toList();
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.product.title),
                      subtitle: Text('${item.product.price} грн x ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => context.read<CartModel>().updateQuantity(item.product.id, -1),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => context.read<CartModel>().updateQuantity(item.product.id, 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => context.read<CartModel>().removeItem(item.product.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (cart.orderError != null)
                      Text('Помилка замовлення: ${cart.orderError}', style: const TextStyle(color: Colors.red)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Разом: ${cart.totalPrice} грн', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          onPressed: (cart.items.isEmpty || cart.isOrdering)
                              ? null
                              : () async {
                                  final success = await context.read<CartModel>().placeOrder();
                                  if (context.mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Замовлення успішно оформлено!')),
                                      );
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                          child: cart.isOrdering
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Оформити замовлення'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}