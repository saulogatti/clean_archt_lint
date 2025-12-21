/// ❌ BAD EXAMPLE: Data importando Presentation na estrutura /lib/src/data/
///
/// Este arquivo demonstra uma VIOLAÇÃO da regra data_no_presentation
/// quando usando a estrutura /lib/src/data/
import 'package:clean_archt_lint_example/src/presentation/pages/product_page.dart'; // ❌ ERROR: Data não pode importar Presentation
import 'package:clean_archt_lint_example/src/core/entities/product.dart';

class BadProductRepository {
  ProductPage getProductPage(String id) {
    // Data não deve conhecer a camada de apresentação
    final product = Product(id: id, name: 'Product', price: 99.99);
    return ProductPage(product: product);
  }
}
