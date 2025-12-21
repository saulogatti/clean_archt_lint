/// Product page in presentation layer with /lib/src/presentation/ structure
///
/// Example of valid file in /lib/src/presentation/ structure
import 'package:flutter/material.dart';
import 'package:clean_archt_lint_example/src/core/entities/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Product: ${product.name}'),
            Text('Price: \$${product.price}'),
          ],
        ),
      ),
    );
  }
}
