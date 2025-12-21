/// ⚠️ BAD EXAMPLE: Presentation importing Data in /lib/src/presentation/ structure
///
/// This file demonstrates a VIOLATION of the presentation_no_data rule
/// when using the /lib/src/presentation/ structure
import 'package:flutter/material.dart';
import 'package:clean_archt_lint_example/src/data/models/product_model.dart'; // ⚠️ WARNING: Presentation should not import Data directly

class BadProductController {
  Future<ProductModel> loadProduct(String id) async {
    // Presentation should not know data implementations
    // Should use only core entities and use cases
    return const ProductModel(id: '1', name: 'Product', price: 99.99);
  }
}
