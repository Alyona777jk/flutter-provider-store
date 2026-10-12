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
      body: const Column(
        children: [
          CategoryFilterWidget(),
          Expanded(child: ProductListWidget()),
        ],
      ),
    );
  }
}

class CategoryFilterWidget extends StatelessWidget {
  const CategoryFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
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

// Картковий віджет товару
class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] ProductTile (${product.title}) build() called');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} грн',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          context.read<CartModel>().addItem(product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} додано!'),
                              duration: const Duration(seconds: 1),
                              action: SnackBarAction(
                                label: 'В кошик',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CartScreen()),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      leading: Image.network(
                        item.product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                      ),
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
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Спосіб оплати:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<PaymentMethod>(
                        segments: const [
                          ButtonSegment<PaymentMethod>(
                            value: PaymentMethod.card,
                            label: Text('Карткою'),
                            icon: Icon(Icons.credit_card),
                          ),
                          ButtonSegment<PaymentMethod>(
                            value: PaymentMethod.cash,
                            label: Text('Готівкою'),
                            icon: Icon(Icons.payments),
                          ),
                        ],
                        selected: {cart.selectedPaymentMethod},
                        onSelectionChanged: (Set<PaymentMethod> newSelection) {
                          context.read<CartModel>().setPaymentMethod(newSelection.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (cart.orderError != null)
                      Text('Помилка: ${cart.orderError}', style: const TextStyle(color: Colors.red)),
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