/// ❌ BAD EXAMPLE: Core importando Data na estrutura /lib/src/core/
///
/// Este arquivo demonstra uma VIOLAÇÃO da regra core_no_data_or_presentation
/// quando usando a estrutura /lib/src/core/
import 'package:clean_archt_lint_example/src/data/models/product_model.dart'; // ❌ ERROR: Core não pode importar Data

class BadGetProduct {
  ProductModel call(String id) {
    // Core não deve conhecer implementações de data
    return const ProductModel(id: '1', name: 'Product', price: 99.99);
  }
}
