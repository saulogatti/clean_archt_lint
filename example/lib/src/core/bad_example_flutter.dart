/// ❌ BAD EXAMPLE: Core importando Flutter na estrutura /lib/src/core/
///
/// Este arquivo demonstra uma VIOLAÇÃO da regra core_no_flutter
/// quando usando a estrutura /lib/src/core/
import 'package:flutter/material.dart'; // ❌ ERROR: Core não pode importar Flutter

class BadProductWidget extends StatelessWidget {
  const BadProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
