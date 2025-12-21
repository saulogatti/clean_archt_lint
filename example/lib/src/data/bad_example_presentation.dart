/// ❌ BAD EXAMPLE: Data importing Presentation in /lib/src/data/ structure
///
/// This file demonstrates a VIOLATION of the data_no_presentation rule
/// when using the /lib/src/data/ structure
import 'package:clean_archt_lint_example/src/presentation/pages/product_page.dart'; // ❌ ERROR: Data cannot import Presentation
import 'package:clean_archt_lint_example/src/core/entities/product.dart';

class BadProductRepository {
  ProductPage getProductPage(String id) {
    // Data should not know the presentation layer
    final product = Product(id: id, name: 'Product', price: 99.99);
    return ProductPage(product: product);
  }
}
