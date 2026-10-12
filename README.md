# Lab 6.2: Provider State Management

**Course:** Mobile Application Development  
**Variant:** Option 1 (E-commerce App)

---

## Overview
A simple mobile store app built with Flutter demonstrating state management using the `provider` package (`^6.1.5`). 

The app features a product catalog with category filtering, detailed item descriptions, product images, a dynamic shopping cart with quantity management, and an order checkout flow supporting multiple payment methods (Card / Cash).

---

## Project Structure & Architecture
The app strictly separates business logic from UI using `ChangeNotifier`:

* **`FakeApi`** (`lib/services/fake_api.dart`): Simulates network requests with a artificial 1-second delay and occasional random server/payment errors.
* **`CatalogModel`** (`lib/models/catalog_model.dart`): Manages products, categories, and async loading states (`loading`, `loaded`, `error`).
* **`CartModel`** (`lib/models/cart_model.dart`): Manages cart items, quantities, selected payment method, total price calculation, and order placement.
* **`MultiProvider`**: Placed at the root above `MaterialApp` to instantiate models via `create`.

---

## State Management Usage (`watch`, `read`, `select`, `Consumer`, `Selector`)

1. **`context.watch`**:
   - Used in `CategoryFilterWidget` to listen for `selectedCategory` updates and rebuild the filter chips when a category changes.

2. **`context.read`**:
   - Used inside event callbacks (button `onPressed` handlers) like adding items to the cart, modifying quantities, switching payment methods, and triggering retries. It avoids unnecessary widget rebuilds when calling methods.

3. **`Consumer`**:
   - Used in `ProductListWidget` to handle asynchronous UI states (`LoadingState.loading`, `LoadingState.error`, `LoadingState.loaded`).
   - Used in `CartScreen` to dynamically render cart items and order summary.

4. **`Selector`**:
   - Used in `CartBadgeIconButton` in the `AppBar`:
     ```dart
     Selector<CartModel, int>(
       selector: (_, cart) => cart.totalItemCount,
       builder: (context, count, child) { ... }
     )
     ```
   - It subscribes **only** to `totalItemCount`. Changes to cart total price or payment method do not trigger a rebuild of the cart badge icon.

---

## Rebuild Optimization Report

To test rendering performance, `debugPrint` calls were added to track `build()` executions before and after implementing `Selector` on the AppBar cart badge.

| Action | `CartBadgeIconButton` Rebuilds BEFORE (`watch`/`Consumer`) | `CartBadgeIconButton` Rebuilds AFTER (`Selector`) |
|---|---|---|
| Adding a new product to cart | 1 | 1 |
| Changing payment method (Card -> Cash) | 1 | **0** |
| Failed checkout attempt | 1 | **0** |
| Switching category filter | 0 | 0 |

*Result:* `Selector` successfully prevented unnecessary badge rebuilds when cart state changed without affecting item count.

---
   ```bash
   git clone [https://github.com/Alyona777jk/flutter-provider-store.git](https://github.com/Alyona777jk/flutter-provider-store.git)
   cd flutter-provider-store
