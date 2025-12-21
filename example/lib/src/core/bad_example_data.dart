/// ❌ BAD EXAMPLE: Core importing Data in /lib/src/core/ structure
///
/// This file demonstrates a VIOLATION of the core_no_data_or_presentation rule
/// when using the /lib/src/core/ structure
import 'package:clean_archt_lint_example/src/data/models/product_model.dart'; // ❌ ERROR: Core cannot import Data

class BadGetProduct {
  ProductModel call(String id) {
    // Core should not know data implementations
    return const ProductModel(id: '1', name: 'Product', price: 99.99);
  }
}
