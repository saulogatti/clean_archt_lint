/// ⚠️ BAD EXAMPLE: Presentation importando Data na estrutura /lib/src/presentation/
///
/// Este arquivo demonstra uma VIOLAÇÃO da regra presentation_no_data
/// quando usando a estrutura /lib/src/presentation/
import 'package:flutter/material.dart';
import 'package:clean_archt_lint_example/src/data/models/product_model.dart'; // ⚠️ WARNING: Presentation não deve importar Data diretamente

class BadProductController {
  Future<ProductModel> loadProduct(String id) async {
    // Presentation não deveria conhecer implementações de data
    // Deveria usar apenas entidades e use cases do core
    return const ProductModel(id: '1', name: 'Product', price: 99.99);
  }
}
