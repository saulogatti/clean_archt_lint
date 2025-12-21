/// ❌ BAD EXAMPLE: Core importing Flutter in /lib/src/core/ structure
///
/// This file demonstrates a VIOLATION of the core_no_flutter rule
/// when using the /lib/src/core/ structure
import 'package:flutter/material.dart'; // ❌ ERROR: Core cannot import Flutter

class BadProductWidget extends StatelessWidget {
  const BadProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
