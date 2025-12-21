/// Product entity in core layer with /lib/src/core/ structure
///
/// Example of valid file in /lib/src/core/ structure
class Product {
  final String id;
  final String name;
  final double price;

  const Product({
    required this.id,
    required this.name,
    required this.price,
  });
}
